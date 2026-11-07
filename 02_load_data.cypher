
// ---------- NÓS ----------

// Usuários
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/users.csv' AS row
MERGE (u:User {user_id: row.user_id})
SET u.name = row.name,
    u.country = row.country,
    u.plan = row.plan,
    u.birth_year = toInteger(row.birth_year),
    u.signup_date = date(row.signup_date);

// Artistas
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/artists.csv' AS row
MERGE (a:Artist {artist_id: row.artist_id})
SET a.name = row.name,
    a.country = row.country,
    a.formed_year = toInteger(row.formed_year);

// Gêneros
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/genres.csv' AS row
MERGE (:Genre {name: row.name});

// Álbuns + (Artist)-[:RELEASED]->(Album)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/albums.csv' AS row
MERGE (al:Album {album_id: row.album_id})
SET al.title = row.title,
    al.release_year = toInteger(row.release_year)
WITH al, row
MATCH (ar:Artist {artist_id: row.artist_id})
MERGE (ar)-[:RELEASED]->(al);

// Faixas + (Album)-[:HAS_TRACK {track_number}]->(Track)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/tracks.csv' AS row
MERGE (t:Track {track_id: row.track_id})
SET t.title = row.title,
    t.duration_sec = toInteger(row.duration_sec),
    t.explicit = (row.explicit = 'true')
WITH t, row
MATCH (al:Album {album_id: row.album_id})
MERGE (al)-[r:HAS_TRACK]->(t)
SET r.track_number = toInteger(row.track_number);

// Playlists + (User)-[:CREATED]->(Playlist)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/playlists.csv' AS row
MERGE (p:Playlist {playlist_id: row.playlist_id})
SET p.name = row.name,
    p.is_public = (row.is_public = 'true'),
    p.created_at = date(row.created_at)
WITH p, row
MATCH (u:User {user_id: row.owner_id})
MERGE (u)-[:CREATED]->(p);

// ---------- RELACIONAMENTOS ----------

// (Track)-[:HAS_GENRE]->(Genre)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/track_genres.csv' AS row
MATCH (t:Track {track_id: row.track_id})
MATCH (g:Genre {name: row.genre})
MERGE (t)-[:HAS_GENRE]->(g);

// (Artist)-[:PERFORMED {role}]->(Track)   role = main | featured
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/artist_tracks.csv' AS row
MATCH (a:Artist {artist_id: row.artist_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (a)-[r:PERFORMED]->(t)
SET r.role = row.role;

// (User)-[:LISTENED_TO {...}]->(Track)  -> um relacionamento por execução (eventos)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/listens.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (u)-[l:LISTENED_TO {listen_id: row.listen_id}]->(t)
SET l.played_at = datetime(row.played_at),
    l.seconds_played = toInteger(row.seconds_played),
    l.device = row.device;

// (User)-[:FOLLOWS {since}]->(User)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/follows_users.csv' AS row
MATCH (a:User {user_id: row.follower_id})
MATCH (b:User {user_id: row.followed_id})
MERGE (a)-[f:FOLLOWS]->(b)
SET f.since = date(row.since);

// (User)-[:FOLLOWS_ARTIST {since}]->(Artist)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/follows_artists.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (a:Artist {artist_id: row.artist_id})
MERGE (u)-[f:FOLLOWS_ARTIST]->(a)
SET f.since = date(row.since);

// (Playlist)-[:INCLUDES {position, added_at}]->(Track)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/playlist_tracks.csv' AS row
MATCH (p:Playlist {playlist_id: row.playlist_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (p)-[i:INCLUDES]->(t)
SET i.position = toInteger(row.position),
    i.added_at = date(row.added_at);

// (User)-[:LIKED {liked_at}]->(Track)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/SEU_USUARIO/spotify-neo4j-aura/main/data/likes.csv' AS row
MATCH (u:User {user_id: row.user_id})
MATCH (t:Track {track_id: row.track_id})
MERGE (u)-[l:LIKED]->(t)
SET l.liked_at = datetime(row.liked_at);
