// Community detection
// 1. Create a cypher project on the "Science" category and another on all the graph minus the countries called "All_no_country"
// 2. Compute the number of triangles per article ("Science", "All_no_country")
// 3. Compute the number of triangles per category ("Science", "All_no_country")
// Path finding
// 4. All shortest path for article with the "Science" category ("All_no_country" is too much for our PCs)
// Centrality
// 5. PageRank ("Science", "All_no_country")
// 6. Degree Centrality ("Science", "All_no_country")
// 7. Closeness ("Science", "All_no_country")
// 8. Betweenness ("Science", "All_no_country")

// Community detection
// 1. Create a cypher project on the "Science" category and another on all the graph minus the countries called "All_no_country"
// 1.1
CALL gds.graph.create.cypher(
"Science",
"MATCH (a:Article) WHERE 'Science' IN a.categories RETURN id(a) AS id",
"MATCH (a1)-[r]->(a2) WHERE 'Science' IN a1.categories AND 'Science' IN a2.categories RETURN id(a1) AS source, id(a2) AS target"
) YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;
// 1.2
CALL gds.graph.create.cypher(
"All_no_country",
"MATCH (a:Article) 
 WHERE NOT ('Countries' IN a.categories OR 'Geography' IN a.categories)
 RETURN id(a) AS id",
"MATCH (a1)-[r]->(a2)
 WHERE NOT ('Countries' IN a1.categories OR 'Countries' IN a2.categories)
       AND NOT ('Geography' IN a1.categories OR 'Geography' IN a2.categories)
 RETURN id(a1) AS source, id(a2) AS target"
) YIELD graphName AS graph, nodeCount AS nodes, relationshipCount AS rels;

// 2. Compute the number of triangles per article ("Science", "All_no_country")
// 2.1
CALL gds.triangleCount.stream("Science")
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name_decoded, triangleCount
ORDER BY triangleCount DESC LIMIT 10;

// 2.2
CALL gds.triangleCount.stream("All_no_country")
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name_decoded, gds.util.asNode(nodeId).categories, triangleCount
ORDER BY triangleCount DESC LIMIT 10;


// 3. Compute the number of triangles per category ("Science", "All_no_country")
// 3.1
CALL gds.triangleCount.stream("Science")
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).categories, SUM(triangleCount) AS triangleCount
ORDER BY triangleCount DESC;

// 3.2
CALL gds.triangleCount.stream("All_no_country")
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).categories, SUM(triangleCount) AS triangleCount
ORDER BY triangleCount DESC;


// Path finding
// 4. All shortest path for article with the "Science" category ("All_no_country" is too much for our PCs)
CALL gds.alpha.allShortestPaths.stream(
{
    nodeQuery:"MATCH (a:Article) WHERE 'Science' IN a.categories RETURN DISTINCT id(a) AS id",
    relationshipQuery:"MATCH (a1:Article)--(a2:Article) WHERE 'Science' IN a1.categories AND 'Science' IN a2.categories RETURN id(a1) as source, id(a2) as target"
})
YIELD sourceNodeId, targetNodeId, distance
RETURN gds.util.asNode(sourceNodeId).name_decoded, gds.util.asNode(targetNodeId).name_decoded, distance
ORDER BY distance DESC LIMIT 10;

// Centrality
// 5. pageRank ("Science", "All_no_country")
// 5.1
CALL gds.pageRank.stream("Science", {
maxIterations: 100,
dampingFactor: 0.85
})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;

// 5.2
CALL gds.pageRank.stream("All_no_country", {
maxIterations: 100,
dampingFactor: 0.85
})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;

// 6. Degree ("Science", "All_no_country")
// 6.1
CALL gds.degree.stream("Science", {})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;

// 6.2
CALL gds.degree.stream("All_no_country", {})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;

// 7. Closeness ("Science", "All_no_country")
// 7.1
CALL gds.alpha.closeness.stream("Science", {})
YIELD nodeId, centrality
RETURN gds.util.asNode(nodeId).name_decoded AS name, centrality
ORDER BY centrality DESC LIMIT 10;

// 7.2
CALL gds.alpha.closeness.stream("All_no_country", {})
YIELD nodeId, centrality
RETURN gds.util.asNode(nodeId).name_decoded AS name, centrality
ORDER BY centrality DESC LIMIT 10;

// 8. Betweeness ("Science", "All_no_country")
// 8.1
CALL gds.betweenness.stream("Science", {})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;

// 8.2
CALL gds.betweenness.stream("All_no_country", {})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name_decoded AS name, score
ORDER BY score DESC LIMIT 10;
