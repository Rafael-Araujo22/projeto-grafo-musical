// =====================================================
// 04 - CONSULTAS DE NEGÓCIO
// =====================================================

// Q1. Quais são as 10 faixas mais ouvidas e quantos minutos foram consumidos?
MATCH (:User)-[l:LISTENED_TO]->(t:Track)
RETURN t.title AS faixa, count(l) AS execucoes, round(sum(l.seconds_played) / 60.0, 1) AS minutos_ouvidos
ORDER BY execucoes DESC, minutos_ouvidos DESC
LIMIT 10;

// Q2. Quais artistas têm mais ouvintes únicos? (inclui participações especiais)
MATCH (u:User)-[l:LISTENED_TO]->(:Track)<-[:PERFORMED]-(a:Artist)
RETURN a.name AS artista, count(DISTINCT u) AS ouvintes_unicos, count(l) AS execucoes
ORDER BY ouvintes_unicos DESC, execucoes DESC;

// Q3. Quais os 3 gêneros mais ouvidos em cada país?
MATCH (u:User)-[l:LISTENED_TO]->(:Track)-[:HAS_GENRE]->(g:Genre)
WITH u.country AS pais, g.name AS genero, count(l) AS execucoes
ORDER BY pais, execucoes DESC
WITH pais, collect({genero: genero, execucoes: execucoes})[0..3] AS top3
RETURN pais, top3
ORDER BY pais;

// Q4. Recomendação de faixas por filtragem colaborativa:
//     "quem ouve o que a Ana ouve também ouviu..."
MATCH (me:User {name: 'Ana Souza'})-[:LISTENED_TO]->(t:Track)<-[:LISTENED_TO]-(other:User)
WHERE other <> me
WITH me, other, count(DISTINCT t) AS faixas_em_comum
ORDER BY faixas_em_comum DESC
LIMIT 5
MATCH (other)-[:LISTENED_TO]->(rec:Track)
WHERE NOT (me)-[:LISTENED_TO]->(rec)
RETURN rec.title AS recomendacao, count(DISTINCT other) AS indicada_por, sum(faixas_em_comum) AS score
ORDER BY score DESC, indicada_por DESC
LIMIT 10;

// Q5. Artistas que os amigos da Ana seguem e ela ainda não segue
MATCH (me:User {name: 'Ana Souza'})-[:FOLLOWS]->(amigo:User)-[:FOLLOWS_ARTIST]->(a:Artist)
WHERE NOT (me)-[:FOLLOWS_ARTIST]->(a)
RETURN a.name AS artista, count(DISTINCT amigo) AS amigos_que_seguem, collect(DISTINCT amigo.name) AS quem
ORDER BY amigos_que_seguem DESC;

// Q6. Rede de colaborações entre artistas (visualização em grafo)
MATCH p = (principal:Artist)-[:PERFORMED {role: 'main'}]->(t:Track)<-[:PERFORMED {role: 'featured'}]-(convidado:Artist)
RETURN p;

// Q7. Faixas que mais aparecem em playlists
MATCH (p:Playlist)-[:INCLUDES]->(t:Track)
RETURN t.title AS faixa, count(p) AS qtd_playlists, collect(p.name) AS playlists
ORDER BY qtd_playlists DESC, faixa
LIMIT 10;

// Q8. Usuários mais influentes (mais seguidores)
MATCH (u:User)<-[f:FOLLOWS]-(:User)
RETURN u.name AS usuario, u.country AS pais, count(f) AS seguidores
ORDER BY seguidores DESC
LIMIT 5;

// Q9. Tempo médio de escuta por plano (Free x Premium x Family)
MATCH (u:User)-[l:LISTENED_TO]->(:Track)
WITH u.plan AS plano, count(DISTINCT u) AS usuarios, sum(l.seconds_played) AS segundos
RETURN plano, usuarios, round(segundos / 3600.0, 2) AS horas_totais,
       round(segundos / 60.0 / usuarios, 1) AS minutos_por_usuario
ORDER BY minutos_por_usuario DESC;

// Q10. Menor caminho social entre dois usuários (graus de separação)
MATCH (a:User {name: 'Carla Mendes'}), (b:User {name: 'Henrique Dias'})
MATCH p = shortestPath((a)-[:FOLLOWS*..6]-(b))
RETURN p, length(p) AS graus_de_separacao;

// Q11. Usuários com gosto mais parecido com o da Ana (similaridade de Jaccard)
MATCH (a:User {name: 'Ana Souza'})-[:LISTENED_TO]->(ta:Track)
WITH a, collect(DISTINCT ta) AS tracksA
MATCH (b:User)-[:LISTENED_TO]->(tb:Track)
WHERE b <> a
WITH tracksA, b, collect(DISTINCT tb) AS tracksB
WITH b, size([x IN tracksA WHERE x IN tracksB]) AS comuns,
     size(tracksA) + size(tracksB) - size([x IN tracksA WHERE x IN tracksB]) AS uniao
WHERE comuns > 0
RETURN b.name AS usuario, comuns, round(toFloat(comuns) / uniao, 3) AS jaccard
ORDER BY jaccard DESC
LIMIT 5;

// Q12. Descoberta: faixas dos 2 gêneros favoritos da Ana que ela ainda não ouviu
MATCH (me:User {name: 'Ana Souza'})-[l:LISTENED_TO]->(:Track)-[:HAS_GENRE]->(g:Genre)
WITH me, g, count(l) AS n
ORDER BY n DESC
LIMIT 2
MATCH (g)<-[:HAS_GENRE]-(rec:Track)<-[:PERFORMED {role: 'main'}]-(a:Artist)
WHERE NOT (me)-[:LISTENED_TO]->(rec)
RETURN g.name AS genero, rec.title AS faixa, a.name AS artista
ORDER BY genero, faixa
LIMIT 10;

// ---------- Visualização para prints (Browser / Explore) ----------
// Mundo da Ana: o que ouve, quem segue e playlists criadas
MATCH p = (u:User {name: 'Ana Souza'})-[:LISTENED_TO|FOLLOWS_ARTIST|FOLLOWS|CREATED]->()
RETURN p LIMIT 60;

// Grafo de um álbum completo: artista, faixas e gêneros
MATCH p = (:Artist)-[:RELEASED]->(:Album {title: 'Cores do Ar'})-[:HAS_TRACK]->(:Track)-[:HAS_GENRE]->(:Genre)
RETURN p;
