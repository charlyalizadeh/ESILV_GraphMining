// Mono partite nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded, categories:split(row.categories, ".")});
CREATE CONSTRAINT articleIdConstraint FOR (a:Article) REQUIRE a.id IS UNIQUE;
// Mono partite relationships
LOAD CSV WITH HEADERS FROM "file:///relationships.csv" AS row
MATCH (a1:Article{id:row.id_from}), (a2:Article{id:row.id_to})
CREATE (a1)-[:LINK]->(a2);


// ARTICLE/CATEGORY
// Bi partite nodes 
// Articles
LOAD CSV WITH HEADERS FROM 'file:///articles.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded});
// Categories
LOAD CSV WITH HEADERS FROM 'file:///categories.csv' AS row
MERGE (a:Category{id:row.id, name:row.name, subcategories:split(row.category, '.')});
CREATE CONSTRAINT articleIdConstraint FOR (n:Article) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT categoryIdConstraint FOR (n:Category) REQUIRE n.id IS UNIQUE;

// Bi partite relationships
LOAD CSV WITH HEADERS FROM "file:///relationships.csv" AS row
MATCH (a:Article{id:row.id_from}), (c:Category{id:row.id_to})
CREATE (a)-[:CATEGORY]->(c);


// ARTICLE/PATH
// Articles
LOAD CSV WITH HEADERS FROM 'file:///articles.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded, categories:split(row.categories, ".")});
// Paths
LOAD CSV WITH HEADERS FROM 'file:///paths.csv' AS row
MERGE (p:Path{
            id:row.id,
            timestamp:row.timestamp,
            duration:row.durationInSec,
            path:split(row.path, ';'),
            rating:row.rating,
            state:row.state,
            target:row.target,
            size:row.size
});
CREATE CONSTRAINT articleIdConstraint FOR (n:Article) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT pathIdConstraint FOR (n:Path) REQUIRE n.id IS UNIQUE;
// Relationships
// IS_IN
LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (a:Article{id:row.id_from}), (p:Path{id:row.id_to})
CREATE (a)-[:IS_IN{place:row.place}]->(p);
// IS_TARGET
MATCH (p:Path)<--(a:Article)
WHERE p.target = a.name_decoded
CREATE (p)<-[r:IS_TARGET]-(a)
RETURN type(r);

