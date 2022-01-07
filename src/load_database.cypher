// Mono partite nodes
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (a:Article{id:row.id, name:row.name, name_decoded:row.name_decoded, categories:split(row.categories, "|")});
CREATE CONSTRAINT articleIdConstraint FOR (a:Article) REQUIRE a.id IS UNIQUE;
// Mono partite relationships
LOAD CSV WITH HEADERS FROM "file:///relationships.csv" AS row
MATCH (a1:Article{id:row.id_from}), (a2:Article{id:row.id_to})
CREATE (a1)-[:LINK]->(a2);


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
