// =====================================================
// 03 - CONFERÊNCIA DA CARGA
// =====================================================

// Nós por label  (esperado: User 16, Artist 10, Album 12, Track 48, Genre 9, Playlist 8 = 103)
MATCH (n) RETURN labels(n)[0] AS label, count(*) AS total ORDER BY total DESC;

// Relacionamentos por tipo  (esperado no total: 632)
//   RELEASED 12 | HAS_TRACK 48 | HAS_GENRE 55 | PERFORMED 55 | LISTENED_TO 248
//   FOLLOWS 41 | FOLLOWS_ARTIST 45 | CREATED 8 | INCLUDES 56 | LIKED 64
MATCH ()-[r]->() RETURN type(r) AS tipo, count(*) AS total ORDER BY total DESC;

// Esquema do grafo (tire print para o README -> images/schema.png)
CALL db.schema.visualization();

// Nós órfãos (esperado: nenhum)
MATCH (n) WHERE NOT (n)--() RETURN labels(n), n LIMIT 10;
