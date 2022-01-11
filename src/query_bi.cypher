// Intro
// 1 Top 10 articles most present in paths
// 2 Article ordered by their average time of the path (DESC) they're in and the number of path they're in (DESC)
// 3 Article ordered by their average time (ASC) of the path they're in and the number of path they're in (DESC)
// 4 Compute ratio of finished on total number of path for articles present in more than 1000 paths
// Link prediction
// 5 Top couples of articles that are the most present in the same paths + some similarities
// Similarity
// 6 Path-wise overlap of the articles (we exclude the path where the article is the target)


//  Intro
// 1 Top 10 articles most present in paths
MATCH (a:Article)-[r]->(p:Path)
RETURN a.name_decoded, count(r) AS nb_path ORDER BY nb_path DESC LIMIT 10

// 2 Article ordered by their average time of the path (DESC) they're in and the number of path they're in (DESC)
MATCH (a:Article)-[r]->(p:Path)
WHERE p.rating <> "UNFINISHED" AND p.rating <> "NULL"
WITH a, COUNT(p) AS nb_path, AVG(toInteger(p.duration)) AS avg_duration
WHERE nb_path > 1000
RETURN a.name_decoded, nb_path, avg_duration AS avg_duration ORDER BY avg_duration, nb_path DESC LIMIT 10

// 3 Article ordered by their average time (ASC) of the path they're in and the number of path they're in (DESC)
MATCH (a:Article)-[r]->(p:Path)
WHERE p.rating <> "UNFINISHED" AND p.rating <> "NULL"
WITH a, COUNT(p) AS nb_path, AVG(toInteger(p.duration)) AS avg_duration
WHERE nb_path > 1000
RETURN a.name_decoded, nb_path, avg_duration ORDER BY avg_duration, nb_path DESC LIMIT 10

// 4 Compute ratio of finished on total number of path for articles present in more than 1000 paths
MATCH (a:Article)
MATCH (p1:Path{rating:"UNFINISHED"})<--(a)
WITH COUNT(p1) AS nb_unfinished, a AS a
MATCH (p2:Path{state:"finished"})<--(a)
WITH a.name_decoded AS name_decoded,
     nb_unfinished AS nb_unfinished,
     COUNT(p2) AS nb_finished
WHERE nb_unfinished + nb_finished > 1000
RETURN name_decoded, nb_unfinished + nb_finished AS nb_path, (nb_finished * 1.0) / (nb_finished + nb_unfinished) AS ratio_finished ORDER BY ratio_finished DESC LIMIT 10


// Link prediction
// 5 Top couples of articles that are the most present in the same paths + some similarities
CALL {
    MATCH (a1:Article)--(r)--(a2:Article)
    WHERE ID(a1) > ID(a2)
    RETURN a1, a2, COUNT(r) AS nb_common_path ORDER BY nb_common_path DESC LIMIT 10
}
RETURN a1.name_decoded, a2.name_decoded,
       gds.alpha.linkprediction.totalNeighbors(a1, a2) AS totalNeighbors,
       gds.alpha.linkprediction.preferentialAttachment(a1, a2) AS prefAtt,
       round(gds.alpha.linkprediction.resourceAllocation(a1, a2) * 100) / 100 AS resourceAll,
       round(gds.alpha.linkprediction.adamicAdar(a1, a2) * 100) / 100 AS academicAdar,
       nb_common_path ORDER BY nb_common_path DESC LIMIT 10


// Similarity
// 6 Path-wise overlap of the articles (we exclude the path where the article is the target)
MATCH (a:Article)-[:IS_IN]-(p:Path)
WHERE NOT (a)-[:IS_TARGET]-(p)
WITH {item: ID(a), categories: COLLECT(ID(p))} AS art_path_dict
WITH COLLECT(art_path_dict) AS data
CALL gds.alpha.similarity.overlap.stream({data: data})
YIELD item1, item2, count1, count2, intersection, similarity
WHERE count1 > 100 AND count2 > 100
RETURN gds.util.asNode(item1).name_decoded AS from, gds.util.asNode(item2).name_decoded AS to,
       count1, count2, intersection, similarity
ORDER BY similarity DESC LIMIT 10
