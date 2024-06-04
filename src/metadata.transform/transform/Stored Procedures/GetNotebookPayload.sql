CREATE PROCEDURE [transform].[GetNotebookPayload]
	(
	@NotebookId INT
	)
AS
BEGIN

    -- Defensive check for results returned
    DECLARE @ResultRowCount INT

    SELECT 
        @ResultRowCount = COUNT(*)
    FROM 
        [transform].[NotebooksLatestVersion] AS ns
    INNER JOIN 
        [transform].[ComputeConnections] AS ccn
    ON
        ns.ComputeConnectionFK = ccn.ComputeConnectionId
    INNER JOIN
        [transform].[Connections] AS cn
    ON 
        cn.ConnectionDisplayName = 'PrimaryResourceGroup'
    INNER JOIN
        [transform].[Connections] AS cn2
    ON 
        cn2.ConnectionDisplayName = 'PrimarySubscription'
    INNER JOIN
        [transform].[Connections] AS cn3
    ON 
        cn3.ConnectionDisplayName = 'PrimaryDataLake' AND cn3.SourceLocation = 'curated'
    INNER JOIN
       [transform].[Connections] AS cn4
    ON 
        cn4.ConnectionDisplayName = 'PrimaryDataLake' AND cn4.SourceLocation = 'cleansed'
    
    WHERE
        ns.NotebookId = @NotebookId

    IF @ResultRowCount = 0
    BEGIN
        RAISERROR('No results returned for the provided Notebook Id. Confirm Dataset is enabled, and related Connections and Notebooks Parameters are enabled.',16,1)
    END


	-- DECLARE @NotebookFullPath NVARCHAR(500)

	SELECT 
        [ccn].[ConnectionLocation] AS 'ComputeWorkspaceURL',
        [ccn].[ComputeLocation] AS 'ComputeClusterId',
        [ccn].[ComputeSize],
        [ccn].[ComputeVersion],
        [ccn].[CountNodes],
        [ccn].[LinkedServiceName] AS 'ComputeLinkedServiceName',
        [ccn].[AzureResourceName] AS 'ComputeResourceName',
        [cn].[SourceLocation] AS 'ResourceGroupName',
        [cn2].[SourceLocation] AS 'SubscriptionId',
        [cn3].[ConnectionLocation] AS 'RawStorageName',
		[cn3].[SourceLocation] AS 'RawContainerName',
        [cn4].[ConnectionLocation] AS 'CleansedStorageName',
		[cn4].[SourceLocation] AS 'CleansedContainerName',
        [cn3].[Username] AS 'CuratedStorageAccessKey',
        [cn4].[Username] AS 'CleansedStorageAccessKey',

        ns.NotebookName,
        ns.NotebookPath + ns.NotebookName AS NotebookFullPath,
        ns.NotebookPath,
		ns.TableDescription,
        ns.VersionNumber,
        ns.Enabled,

        -- @LoadAction AS 'LoadAction',
        --@LastLoadDate AS 'LastLoadDate'
        ns.LastLoadDate
    FROM 
        [transform].[NotebooksLatestVersion] AS ns
    INNER JOIN 
        [transform].[ComputeConnections] AS ccn
    ON
        ns.ComputeConnectionFK = ccn.ComputeConnectionId
    INNER JOIN
        [transform].[Connections] AS cn
    ON 
        cn.ConnectionDisplayName = 'PrimaryResourceGroup'
    INNER JOIN
        [transform].[Connections] AS cn2
    ON 
        cn2.ConnectionDisplayName = 'PrimarySubscription'
    INNER JOIN
        [transform].[Connections] AS cn3
    ON 
        cn3.ConnectionDisplayName = 'PrimaryDataLake' AND cn3.SourceLocation = 'curated'
    INNER JOIN
        [transform].[Connections] AS cn4
    ON 
        cn4.ConnectionDisplayName = 'PrimaryDataLake' AND cn4.SourceLocation = 'cleansed'
    
    WHERE
        ns.NotebookId = @NotebookId

END
GO


