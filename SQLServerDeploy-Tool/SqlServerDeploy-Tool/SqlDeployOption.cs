
using System;
using System.IO;
using System.Linq;

namespace SqlServerDeploy
{


    class SqlDeployOption
    {

        ///<summary>Get or set boolean that specifies whether deployment will block due to platform compatibility.</summary>
        public bool AllowIncompatiblePlatform { get; set; } = true;

        ///<summary>Get or set boolean that specifies if deploy deve continue </summary>
        public bool BlockOnPossibleDataLoss { get; set; } = false;

        ///<summary>Get or set the time for await before timeout exception on deploy </summary>
        public int CommandTimeout { get; set; } = -1;

        ///<summary>Get or set boolean that specifies whether the existing database will be dropped and a new database 
        ///  created before proceeding with the actual deployment actions. Acquires single-user mode before dropping the existing database. 
        //True to drop and re-create the database; otherwise, false. Default is false. </summary>
        public bool CreateNewDatabase { get; set; } = false;

        ///<summary>Get or set boolean that specifies whether default values should be generated to populate NULL columns that are constrained to NOT NULL values.
        /// This is useful when needing to add a new NOT NULL column to an existing table with data.
        /// True if default values should be generated; otherwise false. Default is false.</summary>
        public bool GenerateSmartDefaults { get; set; } = true;

        ///<summary> Get or set boolean that specifies whether the plan verification phase is executed or not.
        /// True to perform plan verification; otherwise, false to skip it. Default is true.</summary>
        public bool VerifyDeployment { get; set; } = true;


        ///<summary>Get or set boolean that specifies whether the target collation will be used for identifier comparison.
        ///False to use the source collation; otherwise, true to use the target collation. Default is false.</summary>
        public bool CompareUsingTargetCollation { get; set; } = false;


        public static implicit operator Microsoft.SqlServer.Dac.DacDeployOptions(SqlDeployOption model)
        {

            if (model == null)
                throw new ArgumentNullException(nameof(model));


            var options = new Microsoft.SqlServer.Dac.DacDeployOptions()
            {
                BackupDatabaseBeforeChanges = true,
                AllowIncompatiblePlatform = model.AllowIncompatiblePlatform,
                BlockOnPossibleDataLoss = model.BlockOnPossibleDataLoss,
                CommandTimeout = model.CommandTimeout,
                CreateNewDatabase = model.CreateNewDatabase,
                GenerateSmartDefaults = model.GenerateSmartDefaults,
                VerifyDeployment = model.VerifyDeployment,
                CompareUsingTargetCollation = model.CompareUsingTargetCollation
            };
            return options;


        }
    }

}
