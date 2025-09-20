-- ================================
-- COTAÇÕES
-- ================================
CREATE TABLE IF NOT EXISTS cotacoes (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  transportador_id BIGINT NOT NULL,
  valor DECIMAL(10,2),
  status INTEGER NOT NULL DEFAULT 0,
  comissao DECIMAL(10,2),
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE cotacoes
  ADD CONSTRAINT IF NOT EXISTS fk_cotacoes_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

ALTER TABLE cotacoes
  ADD CONSTRAINT IF NOT EXISTS fk_cotacoes_transportador FOREIGN KEY (transportador_id) REFERENCES transportadores(id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_cotacoes_frete_transportador
  ON cotacoes (frete_id, transportador_id);

-- ================================
-- MESSAGES (CHAT)
-- ================================
CREATE TABLE IF NOT EXISTS messages (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  sender_type VARCHAR NOT NULL,
  sender_id BIGINT NOT NULL,
  content TEXT NOT NULL,
  status INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE messages
  ADD CONSTRAINT IF NOT EXISTS fk_messages_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

CREATE INDEX IF NOT EXISTS index_messages_on_frete_id_and_created_at
  ON messages (frete_id, created_at);

CREATE INDEX IF NOT EXISTS idx_messages_sender
  ON messages (sender_type, sender_id);

-- ================================
-- HISTÓRICO POSTS
-- ================================
CREATE TABLE IF NOT EXISTS historico_posts (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  conteudo TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE historico_posts
  ADD CONSTRAINT IF NOT EXISTS fk_historico_posts_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

-- ================================
-- HISTÓRICO EMAILS
-- ================================
CREATE TABLE IF NOT EXISTS historico_emails (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  assunto VARCHAR NOT NULL,
  conteudo TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE historico_emails
  ADD CONSTRAINT IF NOT EXISTS fk_historico_emails_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

-- ================================
-- HISTÓRICO PROPOSTAS
-- ================================
CREATE TABLE IF NOT EXISTS historico_propostas (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  valor DECIMAL(10,2),
  observacoes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE historico_propostas
  ADD CONSTRAINT IF NOT EXISTS fk_historico_propostas_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

-- ================================
-- PAGAMENTOS
-- ================================
CREATE TABLE IF NOT EXISTS pagamentos (
  id BIGSERIAL PRIMARY KEY,
  frete_id BIGINT NOT NULL,
  transportador_id BIGINT NOT NULL,
  valor DECIMAL(10,2),
  status VARCHAR NOT NULL DEFAULT 'pendente',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE pagamentos
  ADD CONSTRAINT IF NOT EXISTS fk_pagamentos_frete FOREIGN KEY (frete_id) REFERENCES fretes(id);

ALTER TABLE pagamentos
  ADD CONSTRAINT IF NOT EXISTS fk_pagamentos_transportador FOREIGN KEY (transportador_id) REFERENCES transportadores(id);

CREATE INDEX IF NOT EXISTS idx_pagamentos_frete_transportador
  ON pagamentos (frete_id, transportador_id);

-- ================================
-- ADMIN USERS
-- ================================
CREATE TABLE IF NOT EXISTS admin_users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR NOT NULL DEFAULT '',
  encrypted_password VARCHAR NOT NULL DEFAULT '',
  reset_password_token VARCHAR,
  reset_password_sent_at TIMESTAMP,
  remember_created_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS index_admin_users_on_email
  ON admin_users (email);

CREATE UNIQUE INDEX IF NOT EXISTS index_admin_users_on_reset_password_token
  ON admin_users (reset_password_token);

