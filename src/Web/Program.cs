using DasMulli.AspNetCore.Hosting.WindowsServices;
using DasMulli.Win32.ServiceUtils;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Identity;
using Microsoft.eShopWeb.Infrastructure.Data;
using Microsoft.eShopWeb.Infrastructure.Identity;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;

namespace Microsoft.eShopWeb.Web
{
    public class Program
    {
        private const string RunAsServiceFlag = "--service";
        private static string _databaseEngine;
        public static string DatabaseEngine => _databaseEngine;

        public static void Main(string[] args)
        {
            try
            {
                var config = new ConfigurationBuilder().AddJsonFile("appSettings.json").Build();
                var dbSettings = config.Get<DatabaseSettings>();
                _databaseEngine = dbSettings.DatabaseEngine;

                if (args.Contains(RunAsServiceFlag))
                {
                    args = args.Where(a => a != RunAsServiceFlag).ToArray();
                    RunAsService(args);
                }
                else
                {
                    RunInteractive(args);
                }

            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }
        
        private static void RunInteractive(String[] args)
        {
            IWebHost host = BuildWebHost(args);

            host.Run();
        }

        private static void RunAsService(String[] args)
        {
            var assemblyLocationFolder = System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().Location);
            if (string.Compare(Environment.CurrentDirectory, assemblyLocationFolder, StringComparison.OrdinalIgnoreCase) != 0)
            {
                Environment.CurrentDirectory = assemblyLocationFolder;
            }
            IWebHost host = BuildWebHost(args);

            host.RunAsService();
        }

        private static IWebHost BuildWebHost(string[] args)
        {
            var host = CreateWebHostBuilder(args)
                        .Build();

            using (var scope = host.Services.CreateScope())
            {
                var services = scope.ServiceProvider;
                var loggerFactory = services.GetRequiredService<ILoggerFactory>();
                try
                {
                    var catalogContext = services.GetRequiredService<CatalogContext>();
                    CatalogContextSeed.SeedAsync(catalogContext, loggerFactory).Wait();

                    var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
                    AppIdentityDbContextSeed.SeedAsync(userManager).Wait();
                }
                catch (Exception ex)
                {
                    var logger = loggerFactory.CreateLogger<Program>();
                    logger.LogError(ex, "An error occurred seeding the DB.");
                }
            }

            return host;
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration(builder =>
                    builder.AddJsonFile("appSettings.json")
                           .AddSystemsManager($"/{GetParameterPrefix()}")
                )
                .UseUrls("http://*:80")
                .UseStartup<Startup>();

        private static string GetParameterPrefix()
        {
            string parameterPrefix;
            Console.WriteLine($"Using database engine: {Program.DatabaseEngine}");

#if DEBUG
            parameterPrefix = $"cpu-workshop/{Program.DatabaseEngine}";
#else
            parameterPrefix = $"{System.Environment.GetEnvironmentVariable("DB_PARAMETER_PREFIX")}/{Program.DatabaseEngine}";
#endif
            return parameterPrefix;
        }
    }
}
