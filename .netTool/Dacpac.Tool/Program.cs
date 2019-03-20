using System;
using System.Linq;
using System.Reflection;
using System.Threading;
using Microsoft.Build.Globbing;
using Microsoft.Extensions.Configuration;
using Microsoft.SqlServer.Dac;

namespace Dacpac.Tool
{
    class Program
    {
        private static IConfiguration _configuration;



        public const string DacDeployOptionsKey = "DacDeployOptions";


        static void Main(string[] args)
        {
            args = args?.SkipWhile(string.IsNullOrWhiteSpace).ToArray();

            if (args?.Any() == false || args[0].Equals("version", StringComparison.CurrentCultureIgnoreCase))
            {
                Console.WriteLine("Version: {0}", Version());
#if DEBUG
                Main(Console.ReadLine()?.Split(" "));
#endif

            }
            else if (args[0].Equals("publish", StringComparison.CurrentCultureIgnoreCase))
            {
                ConfigurationBuild(args);
                Publish();
            }

            Finished();
        }


        static void Finished()
        {

            Console.WriteLine("Good bye!");
            Thread.Sleep(2000);

        }

        private static void Publish()
        {
            var option = _configuration.GetSection(DacDeployOptionsKey).Get<DacDeployOptions>() ??
                         new DacDeployOptions();
            var dacPackageOptions = _configuration.Get<DacPackageOptions>() ??
                                    new DacPackageOptions();

            var envs = _configuration.AsEnumerable().ToArray();
          #if DEBUG
            foreach (var env in envs)
            {
                Console.WriteLine($"{env.Key}={env.Value}");
            }
            #endif

            var package = dacPackageOptions.FindDacPackage();
            foreach (var connection in dacPackageOptions.Connections)
            {
                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("Starting deploy on {0}", connection.Key);
                var dacService = new DacServices(connection.Value);
                dacService.ProgressChanged += DacService_ProgressChanged;
                dacService.Deploy(package, connection.Key, true, option);
                Console.WriteLine("Finished {0}", connection.Key);
            }

        }

        private static void DacService_ProgressChanged(object sender, DacProgressEventArgs e)
        {
            Console.WriteLine($"{e.Message}: {DateTimeOffset.Now:HH:mm:sss tt zzzz}");
            if (e.Status == DacOperationStatus.Completed)
            {
                Console.WriteLine("-".PadRight(15, '-'));
            }

        }

        static string Version()
        {

            var versionString = Assembly.GetEntryAssembly()
                .GetCustomAttribute<AssemblyInformationalVersionAttribute>()
                .InformationalVersion
                .ToString();
            return versionString;
        }

        static void ConfigurationBuild(string[] args)
        {
            _configuration = new Microsoft.Extensions.Configuration.ConfigurationBuilder()
                  .AddEnvironmentVariables()
                  .AddCommandLine(args)
                  .Build();


        }

    }

}
