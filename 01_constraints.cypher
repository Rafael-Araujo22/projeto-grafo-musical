// =====================================================
// 01 - CONSTRAINTS (rode ANTES da carga)
// Garantem unicidade e criam índice automaticamente,
// o que deixa o MERGE/MATCH da carga muito mais rápido.
// =====================================================
CREATE CONSTRAINT user_id     IF NOT EXISTS FOR (n:User)     REQUIRE n.user_id IS UNIQUE;
CREATE CONSTRAINT artist_id   IF NOT EXISTS FOR (n:Artist)   REQUIRE n.artist_id IS UNIQUE;
CREATE CONSTRAINT album_id    IF NOT EXISTS FOR (n:Album)    REQUIRE n.album_id IS UNIQUE;
CREATE CONSTRAINT track_id    IF NOT EXISTS FOR (n:Track)    REQUIRE n.track_id IS UNIQUE;
CREATE CONSTRAINT genre_name  IF NOT EXISTS FOR (n:Genre)    REQUIRE n.name IS UNIQUE;
CREATE CONSTRAINT playlist_id IF NOT EXISTS FOR (n:Playlist) REQUIRE n.playlist_id IS UNIQUE;
