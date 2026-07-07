// Output BEFORE optimasation
}
explainVersion: '1',
  queryPlanner: {
    namespace: 'bookstore.books',
    parsedQuery: {
      '$and': [
        {
          category: {
            '$eq': 'Programming'
          }
        },
        {
          published_year: {
            '$gte': 2020
          }
        }
      ]
    },
    indexFilterSet: false,
    queryHash: '702E1AA4',
    planCacheShapeHash: '702E1AA4',
    planCacheKey: '57EDA254',
    optimizationTimeMillis: 1,
    maxIndexedOrSolutionsReached: false,
    maxIndexedAndSolutionsReached: false,
    maxScansToExplodeReached: false,
    prunedSimilarIndexes: false,
    winningPlan: {
      isCached: false,
      stage: 'COLLSCAN',
      filter: {
        '$and': [
          {
            category: {
              '$eq': 'Programming'
            }
          },
          {
            published_year: {
              '$gte': 2020
            }
          }
        ]
      },
      direction: 'forward'
    },
    rejectedPlans: []
  },
  executionStats: {
    executionSuccess: true,
    nReturned: 1,
    executionTimeMillis: 2,
    totalKeysExamined: 0,
    totalDocsExamined: 34,
    executionStages: {
      isCached: false,
      stage: 'COLLSCAN',
      filter: {
        '$and': [
          {
            category: {
              '$eq': 'Programming'
            }
          },
          {
            published_year: {
              '$gte': 2020
            }
          }
        ]
      },
      nReturned: 1,
      executionTimeMillisEstimate: 0,
      works: 35,
      advanced: 1,
      needTime: 33,
      needYield: 0,
      saveState: 0,
      restoreState: 0,
      isEOF: 1,
      direction: 'forward',
      docsExamined: 34
    }
  },
  queryShapeHash: '645208F9B71E861ACE7FF0DDB2AC0305644AC41E7B68CF04AB331BF413CBCEA4',
  command: {
    find: 'books',
    filter: {
      category: 'Programming',
      published_year: {
        '$gte': 2020
      }
    },
    '$db': 'bookstore'
  },
  serverInfo: {
    host: '7d08e4f46dc9',
    port: 27017,
    version: '8.2.11',
    gitVersion: 'ee01d36638a00a07a6aa42ee80a125890f11aeed'
  },
  serverParameters: {
    internalQueryFacetBufferSizeBytes: 104857600,
    internalQueryFacetMaxOutputDocSizeBytes: 104857600,
    internalLookupStageIntermediateDocumentMaxSizeBytes: 104857600,
    internalDocumentSourceGroupMaxMemoryBytes: 104857600,
    internalQueryMaxBlockingSortMemoryUsageBytes: 104857600,
    internalQueryProhibitBlockingMergeOnMongoS: 0,
    internalQueryMaxAddToSetBytes: 104857600,
    internalDocumentSourceSetWindowFieldsMaxMemoryBytes: 104857600,
    internalQueryFrameworkControl: 'trySbeRestricted',
    internalQueryPlannerIgnoreIndexWithCollationForRegex: 1
  },
  ok: 1
}

// OUtput AFTER optimisation
{
  explainVersion: '1',
  queryPlanner: {
    namespace: 'bookstore.books',
    parsedQuery: {
      '$and': [
        {
          category: {
            '$eq': 'Programming'
          }
        },
        {
          published_year: {
            '$gte': 2020
          }
        }
      ]
    },
    indexFilterSet: false,
    queryHash: '702E1AA4',
    planCacheShapeHash: '702E1AA4',
    planCacheKey: '4C5FF9D1',
    optimizationTimeMillis: 7,
    maxIndexedOrSolutionsReached: false,
    maxIndexedAndSolutionsReached: false,
    maxScansToExplodeReached: false,
    prunedSimilarIndexes: false,
    winningPlan: {
      isCached: false,
      stage: 'FETCH',
      inputStage: {
        stage: 'IXSCAN',
        keyPattern: {
          category: 1,
          published_year: 1
        },
        indexName: 'category_1_published_year_1',
        isMultiKey: false,
        multiKeyPaths: {
          category: [],
          published_year: []
        },
        isUnique: false,
        isSparse: false,
        isPartial: false,
        indexVersion: 2,
        direction: 'forward',
        indexBounds: {
          category: [
            '["Programming", "Programming"]'
          ],
          published_year: [
            '[2020, inf]'
          ]
        }
      }
    },
    rejectedPlans: []
  },
  executionStats: {
    executionSuccess: true,
    nReturned: 1,
    executionTimeMillis: 15,
    totalKeysExamined: 1,
    totalDocsExamined: 1,
    executionStages: {
      isCached: false,
      stage: 'FETCH',
      nReturned: 1,
      executionTimeMillisEstimate: 0,
      works: 2,
      advanced: 1,
      needTime: 0,
      needYield: 0,
      saveState: 0,
      restoreState: 0,
      isEOF: 1,
      docsExamined: 1,
      alreadyHasObj: 0,
      inputStage: {
        stage: 'IXSCAN',
        nReturned: 1,
        executionTimeMillisEstimate: 0,
        works: 2,
        advanced: 1,
        needTime: 0,
        needYield: 0,
        saveState: 0,
        restoreState: 0,
        isEOF: 1,
        keyPattern: {
          category: 1,
          published_year: 1
        },
        indexName: 'category_1_published_year_1',
        isMultiKey: false,
        multiKeyPaths: {
          category: [],
          published_year: []
        },
        isUnique: false,
        isSparse: false,
        isPartial: false,
        indexVersion: 2,
        direction: 'forward',
        indexBounds: {
          category: [
            '["Programming", "Programming"]'
          ],
          published_year: [
            '[2020, inf]'
          ]
        },
        keysExamined: 1,
        seeks: 1,
        dupsTested: 0,
        dupsDropped: 0
      }
    }
  },
  queryShapeHash: '645208F9B71E861ACE7FF0DDB2AC0305644AC41E7B68CF04AB331BF413CBCEA4',
  command: {
    find: 'books',
    filter: {
      category: 'Programming',
      published_year: {
        '$gte': 2020
      }
    },
    '$db': 'bookstore'
  },
  serverInfo: {
    host: '7d08e4f46dc9',
    port: 27017,
    version: '8.2.11',
    gitVersion: 'ee01d36638a00a07a6aa42ee80a125890f11aeed'
  },
  serverParameters: {
    internalQueryFacetBufferSizeBytes: 104857600,
    internalQueryFacetMaxOutputDocSizeBytes: 104857600,
    internalLookupStageIntermediateDocumentMaxSizeBytes: 104857600,
    internalDocumentSourceGroupMaxMemoryBytes: 104857600,
    internalQueryMaxBlockingSortMemoryUsageBytes: 104857600,
    internalQueryProhibitBlockingMergeOnMongoS: 0,
    internalQueryMaxAddToSetBytes: 104857600,
    internalDocumentSourceSetWindowFieldsMaxMemoryBytes: 104857600,
    internalQueryFrameworkControl: 'trySbeRestricted',
    internalQueryPlannerIgnoreIndexWithCollationForRegex: 1
  },
  ok: 1
}
