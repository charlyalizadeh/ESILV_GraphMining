# Graph and Data Mining project: Wikispedia (ESILV)

## Setup and installation


* Build the dataset to import into Neo4j

```bash
tar -xvf data/wikispeedia_paths-and-graph.tar.gz -C data/
mkdir -p data/mono_partite
mkdir -p data/bi_partite
python -m venv .venv # (OS dependant)
source .venv/bin/activate # (shell dependant)
pip install -r requirements.txt
python src/build_dataset.py
```

* Create a new project and two database (mono_partite and bi_partite)
* Move the csv file from the directory "data/mono_partite" to the import folder of the mono_partite database (`🞄🞄🞄` -> `Open folder` -> `Import`)
* Move the csv file from the directory "data/bi_partite" to the import folder of the bi_partite database

* Open the mono_partite database and load the data:

```cypher
// Mono partite nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded, categories:split(row.categories, ".")});
CREATE CONSTRAINT articleIdConstraint FOR (a:Article) REQUIRE a.id IS UNIQUE;

// Mono partite relationships
LOAD CSV WITH HEADERS FROM "file:///relationships.csv" AS row
MATCH (a1:Article{id:row.id_from}), (a2:Article{id:row.id_to})
CREATE (a1)-[:LINK]->(a2);
```
* Close the mono_partite database, open the bi_partite database and import the data:

```cypher
// Bi partite

// Articles
LOAD CSV WITH HEADERS FROM 'file:///articles.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded, categories:split(row.categories, ".")});
CREATE CONSTRAINT articleIdConstraint FOR (n:Article) REQUIRE n.id IS UNIQUE;

// Paths
LOAD CSV WITH HEADERS FROM 'file:///paths.csv' AS row
MERGE (p:Path{
            id:row.id,
            timestamp:row.timestamp,
            duration:row.durationInSec,
            path:split(row.path, ';'),
            rating:row.rating,
            state:row.state,
            target:row.target
});
CREATE CONSTRAINT pathIdConstraint FOR (n:Path) REQUIRE n.id IS UNIQUE;

// Relationships
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (a:Article{id:row.id_from}), (p:Path{id:row.id_to})
CREATE (a)-[:IS_IN]->(p);
```
