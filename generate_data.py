"""Gera os CSVs do projeto Spotify-like (determinístico: seed fixa).
Uso: python scripts/generate_data.py
Todos os artistas, álbuns e faixas são FICTÍCIOS (não há direitos autorais envolvidos).
"""
import csv, random
from collections import deque
from datetime import datetime, timedelta, date
from pathlib import Path

random.seed(42)
DATA = Path(__file__).resolve().parent.parent / "data"
DATA.mkdir(exist_ok=True)

def write(name, header, rows):
    with open(DATA / name, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(header)
        w.writerows(rows)
    print(f"{name}: {len(rows)} linhas")
    return len(rows)

def rand_date(a, b):
    return a + timedelta(days=random.randint(0, (b - a).days))

# ---------------- Gêneros ----------------
genres = ["MPB", "Rock", "Eletrônica", "Pop", "Jazz", "Hip Hop", "Sertanejo", "Indie", "Samba"]

# ---------------- Artistas ----------------
artists = [
    ("A01", "Luna Vermelha", "BR", 2012), ("A02", "Os Faróis", "BR", 2008),
    ("A03", "DJ Maré Alta", "BR", 2015), ("A04", "Nova Aurora", "US", 2010),
    ("A05", "Atlas Quartet", "UK", 2005), ("A06", "Rua 7 MC", "BR", 2016),
    ("A07", "Violeta Sertão", "BR", 2011), ("A08", "Neon Harbor", "US", 2014),
    ("A09", "Mar de Cobre", "PT", 2009), ("A10", "Trio Samba Azul", "BR", 2003),
]

# ---------------- Álbuns: (id, título, artista, ano, gênero1, gênero2, [4 faixas]) ----------------
albums = [
    ("AL01", "Horizonte Raro", "A01", 2018, "MPB", "Pop", ["Maré de Janeiro", "Sol de Papel", "Caminho Estreito", "Varanda"]),
    ("AL02", "Cores do Ar", "A01", 2021, "MPB", "Indie", ["Azul Elétrico", "Vento Sul", "Pele de Cor", "Domingo Lento"]),
    ("AL03", "Estrada de Ferro", "A02", 2016, "Rock", None, ["Trem das Onze", "Poeira", "Guitarras ao Amanhecer", "Última Estação"]),
    ("AL04", "Faróis Acesos", "A02", 2022, "Rock", "Indie", ["Farol Aceso", "Noite Adentro", "Voltar pra Casa", "Ruído Branco"]),
    ("AL05", "Pulso Digital", "A03", 2020, "Eletrônica", "Pop", ["Batida 128", "Pulso", "Neon Sul", "Loop Infinito"]),
    ("AL06", "Midnight Glow", "A04", 2019, "Pop", None, ["Midnight Glow", "Paper Hearts", "Run Tonight", "Golden Static"]),
    ("AL07", "Blue Hours", "A05", 2017, "Jazz", None, ["Blue Hours", "Smoke Signals", "Quarter Past Two", "Velvet Rain"]),
    ("AL08", "Asfalto Quente", "A06", 2021, "Hip Hop", None, ["Asfalto Quente", "Quebrada Viva", "Rima de Esquina", "Fim de Tarde"]),
    ("AL09", "Coração de Viola", "A07", 2019, "Sertanejo", None, ["Coração de Viola", "Poeira da Estrada", "Saudade de Casa", "Boiadeiro"]),
    ("AL10", "Waves & Wires", "A08", 2023, "Eletrônica", "Pop", ["Waves & Wires", "Digital Tide", "Satellite Love", "After Hours Club"]),
    ("AL11", "Cartas ao Mar", "A09", 2018, "Indie", "MPB", ["Cartas ao Mar", "Casa Pequena", "Vinho e Sal", "Montanha"]),
    ("AL12", "Roda Viva Azul", "A10", 2015, "Samba", "MPB", ["Roda Viva Azul", "Pandeiro", "Lua de Samba", "Feijoada de Domingo"]),
]

# Participações especiais: (álbum, nº da faixa) -> artista convidado
features = {("AL02", 2): "A09", ("AL04", 3): "A01", ("AL05", 1): "A06", ("AL06", 2): "A08",
            ("AL08", 3): "A01", ("AL10", 4): "A03", ("AL11", 1): "A10"}

tracks, track_genres, artist_tracks, track_info = [], [], [], {}
artist_genres = {a[0]: set() for a in artists}
for i, (al_id, _, art, _, g1, g2, names) in enumerate(albums):
    artist_genres[art] |= {g for g in (g1, g2) if g}
    for n, title in enumerate(names, 1):
        tid = f"T{i*4+n:03d}"
        dur = random.randint(150, 320)
        explicit = (g1 == "Hip Hop" and n != 4)
        tracks.append([tid, title, dur, str(explicit).lower(), al_id, n])
        gs = [g1] + ([g2] if (g2 and n == 3) else [])
        for g in gs:
            track_genres.append([tid, g])
        artist_tracks.append([art, tid, "main"])
        if (al_id, n) in features:
            artist_tracks.append([features[(al_id, n)], tid, "featured"])
        track_info[tid] = {"genres": gs, "dur": dur}

# ---------------- Usuários ----------------
users = [
    ("U01", "Ana Souza", "BR", "Premium", 1995, ["MPB", "Indie"]),
    ("U02", "Bruno Lima", "BR", "Free", 1990, ["Rock", "Hip Hop"]),
    ("U03", "Carla Mendes", "BR", "Premium", 1998, ["Pop", "Eletrônica"]),
    ("U04", "Diego Alves", "BR", "Family", 1987, ["Sertanejo", "MPB"]),
    ("U05", "Eduarda Rocha", "BR", "Premium", 2001, ["Pop", "Hip Hop"]),
    ("U06", "Felipe Costa", "BR", "Free", 1993, ["Rock", "Indie"]),
    ("U07", "Gabriela Nunes", "BR", "Premium", 1996, ["Samba", "MPB"]),
    ("U08", "Henrique Dias", "BR", "Free", 1985, ["Jazz", "MPB"]),
    ("U09", "Isabela Martins", "PT", "Premium", 1994, ["Indie", "Jazz"]),
    ("U10", "João Pereira", "PT", "Free", 1999, ["Eletrônica", "Pop"]),
    ("U11", "Karen Smith", "US", "Premium", 1992, ["Pop", "Eletrônica"]),
    ("U12", "Liam Johnson", "US", "Family", 1989, ["Rock", "Jazz"]),
    ("U13", "Mariana Oliveira", "BR", "Premium", 2003, ["Hip Hop", "Eletrônica"]),
    ("U14", "Nicolas Ferreira", "BR", "Free", 1991, ["Sertanejo", "Rock"]),
    ("U15", "Olívia Santos", "BR", "Premium", 1997, ["MPB", "Samba"]),
    ("U16", "Pedro Gomes", "AR", "Free", 2000, ["Rock", "Eletrônica"]),
]
user_rows = [[u[0], u[1], u[2], u[3], u[4], rand_date(date(2022, 1, 1), date(2025, 10, 31)).isoformat()] for u in users]

# ---------------- Execuções (LISTENED_TO) ----------------
devices = ["mobile", "desktop", "speaker", "tv"]
start, span = datetime(2026, 9, 1), 61 * 24 * 60
raw_listens, user_listened = [], {u[0]: [] for u in users}
for uid, _, _, _, _, prefs in users:
    pool = [t for t, i in track_info.items() if set(i["genres"]) & set(prefs)]
    for _ in range(random.randint(12, 18)):
        t = random.choice(pool) if random.random() < 0.75 else random.choice(list(track_info))
        ts = start + timedelta(minutes=random.randint(0, span))
        secs = int(track_info[t]["dur"] * random.uniform(0.3, 1.0))
        raw_listens.append((ts, uid, t, secs, random.choice(devices)))
        user_listened[uid].append((t, ts))
raw_listens.sort()
listens = [[f"L{i:04d}", uid, t, ts.isoformat(timespec="seconds"), secs, dev]
           for i, (ts, uid, t, secs, dev) in enumerate(raw_listens, 1)]

# ---------------- Seguidores (usuário -> usuário) ----------------
fu = set()
for u in users:
    others = [o for o in users if o[0] != u[0]]
    weights = [1 + 3 * len(set(u[5]) & set(o[5])) + (2 if u[2] == o[2] else 0) for o in others]
    k = random.randint(2, 3)
    chosen = set()
    while len(chosen) < k:
        chosen.add(random.choices(others, weights)[0][0])
    fu |= {(u[0], c) for c in chosen}
follows_users = [[a, b, rand_date(date(2023, 1, 1), date(2026, 8, 31)).isoformat()] for a, b in sorted(fu)]

# ---------------- Seguidores (usuário -> artista) ----------------
follows_artists = []
for u in users:
    cands = [a for a, gs in artist_genres.items() if gs & set(u[5])]
    for a in random.sample(cands, min(3, len(cands))):
        follows_artists.append([u[0], a, rand_date(date(2023, 1, 1), date(2026, 8, 31)).isoformat()])

# ---------------- Playlists ----------------
pl_defs = [("P01", "Foco Total", "U03"), ("P02", "Estrada e Violão", "U04"), ("P03", "Rock de Garagem", "U06"),
           ("P04", "Noite de Jazz", "U08"), ("P05", "Domingo de Samba", "U07"), ("P06", "Treino Pesado", "U13"),
           ("P07", "Chill Indie", "U09"), ("P08", "MPB Essencial", "U01")]
umap = {u[0]: u for u in users}
playlists, playlist_tracks = [], []
for pid, name, owner in pl_defs:
    created = rand_date(date(2024, 1, 1), date(2026, 6, 30))
    playlists.append([pid, name, str(random.random() < 0.75).lower(), owner, created.isoformat()])
    prefs = umap[owner][5]
    pool = [t for t, i in track_info.items() if set(i["genres"]) & set(prefs)]
    for pos, t in enumerate(random.sample(pool, 7), 1):
        playlist_tracks.append([pid, t, pos, (created + timedelta(days=random.randint(0, 60))).isoformat()])

# ---------------- Curtidas ----------------
likes = []
for uid, hist in user_listened.items():
    seen = {}
    for t, ts in hist:
        seen.setdefault(t, ts)
    for t in random.sample(list(seen), min(4, len(seen))):
        likes.append([uid, t, (seen[t] + timedelta(minutes=random.randint(1, 120))).isoformat(timespec="seconds")])

# ---------------- Escrita ----------------
counts = {}
counts["User"] = write("users.csv", ["user_id", "name", "country", "plan", "birth_year", "signup_date"], user_rows)
counts["Artist"] = write("artists.csv", ["artist_id", "name", "country", "formed_year"], [list(a) for a in artists])
counts["Album"] = write("albums.csv", ["album_id", "title", "artist_id", "release_year"], [[a[0], a[1], a[2], a[3]] for a in albums])
counts["Track"] = write("tracks.csv", ["track_id", "title", "duration_sec", "explicit", "album_id", "track_number"], tracks)
counts["Genre"] = write("genres.csv", ["name"], [[g] for g in genres])
counts["HAS_GENRE"] = write("track_genres.csv", ["track_id", "genre"], track_genres)
counts["PERFORMED"] = write("artist_tracks.csv", ["artist_id", "track_id", "role"], artist_tracks)
counts["LISTENED_TO"] = write("listens.csv", ["listen_id", "user_id", "track_id", "played_at", "seconds_played", "device"], listens)
counts["FOLLOWS"] = write("follows_users.csv", ["follower_id", "followed_id", "since"], follows_users)
counts["FOLLOWS_ARTIST"] = write("follows_artists.csv", ["user_id", "artist_id", "since"], follows_artists)
counts["Playlist"] = write("playlists.csv", ["playlist_id", "name", "is_public", "owner_id", "created_at"], playlists)
counts["INCLUDES"] = write("playlist_tracks.csv", ["playlist_id", "track_id", "position", "added_at"], playlist_tracks)
counts["LIKED"] = write("likes.csv", ["user_id", "track_id", "liked_at"], likes)

# ---------------- Conferência (para o README) ----------------
nodes = sum(counts[k] for k in ["User", "Artist", "Album", "Track", "Genre", "Playlist"])
rels = (counts["Album"] + counts["Track"] + counts["HAS_GENRE"] + counts["PERFORMED"] + counts["LISTENED_TO"]
        + counts["FOLLOWS"] + counts["FOLLOWS_ARTIST"] + counts["Playlist"] + counts["INCLUDES"] + counts["LIKED"])
print(f"\nTOTAL nós: {nodes} | TOTAL relacionamentos: {rels}")

adj = {u[0]: set() for u in users}
for a, b, _ in follows_users:
    adj[a].add(b); adj[b].add(a)
best = (0, None, None)
for s in adj:
    dist, q = {s: 0}, deque([s])
    while q:
        x = q.popleft()
        for y in adj[x]:
            if y not in dist:
                dist[y] = dist[x] + 1; q.append(y)
    for t, d in dist.items():
        if d > best[0]:
            best = (d, s, t)
print("Maior distância (FOLLOWS, não direcionado):", best[0], umap[best[1]][1], "->", umap[best[2]][1])
