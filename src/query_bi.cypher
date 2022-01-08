// 1. Top 10 articles most present in paths
// 2. Article ordered by their average time of the path (DESC) they're in and the number of path they're in (DESC)
// 3. Article ordered by their average time (ASC) of the path they're in and the number of path they're in (DESC)
// 4. Compute ratio of finished on total number of path for articles present in more than 100 paths
// 5. Top couples of articles that are the most present in the same paths + some similarity on their categories

// 1. Top 10 articles most present in paths
MATCH (a:Article)-[r]->(p:Path)
RETURN a.name_decoded, count(r) AS nb_path ORDER BY nb_path DESC

// 2. Article ordered by their average time of the path (DESC) they're in and the number of path they're in (DESC)
MATCH (a:Article)-[r]->(p:Path)
WHERE p.rating <> "UNFINISHED" AND p.rating <> "NULL"
RETURN a.name_decoded, COUNT(p) as nb_path, AVG(toInteger(p.duration)) AS avg_duration ORDER BY avg_duration DESC, nb_path DESC

// 3. Article ordered by their average time (ASC) of the path they're in and the number of path they're in (DESC)
MATCH (a:Article)-[r]->(p:Path)
WHERE p.rating <> "UNFINISHED" AND p.rating <> "NULL"
RETURN a.name_decoded, COUNT(p) as nb_path, AVG(toInteger(p.duration)) AS avg_duration ORDER BY avg_duration, nb_path DESC

// 4. Compute ratio of finished on total number of path for articles present in more than 100 paths
MATCH (a:Article)
MATCH (p1:Path{rating:"UNFINISHED"})<--(a)
WITH COUNT(p1) AS nb_unfinished, a AS a
MATCH (p2:Path{state:"finished"})<--(a)
WITH a.name_decoded AS name_decoded,
     nb_unfinished AS nb_unfinished,
     COUNT(p2) AS nb_finished
WHERE nb_unfinished + nb_finished > 1000
RETURN name_decoded, nb_unfinished + nb_finished AS nb_path, (nb_finished * 1.0) / (nb_finished + nb_unfinished) AS ratio_finished ORDER BY ratio_finished DESC

// 5. Top couples of articles that are the most present in the same paths + some similarity on their categories
CALL {
    MATCH (a1:Article)--(r)--(a2:Article)
    WHERE ID(a1) > ID(a2)
    RETURN a1, a2, COUNT(r) AS nb_common_path ORDER BY nb_common_path DESC LIMIT 10
}
RETURN a1.name_decoded, a2.name_decoded,
       gds.alpha.linkprediction.totalNeighbors(a1, a2) AS totalNeighbors,
       gds.alpha.linkprediction.preferentialAttachment(a1, a2) AS prefAtt,
       gds.alpha.linkprediction.resourceAllocation(a1, a2) AS resourceAll,
       gds.alpha.linkprediction.adamicAdar(a1, a2) AS academicAdar,
       nb_common_path ORDER BY nb_common_path DESC LIMIT 10
