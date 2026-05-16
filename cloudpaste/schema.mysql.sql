-- 直播训练营积分统计系统 - MySQL 数据库结构
-- 执行方式: mysql -u root -p live_camp_stats < schema.mysql.sql

-- 创建数据库
CREATE DATABASE IF NOT EXISTS live_camp_stats DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE live_camp_stats;

-- 活动表
CREATE TABLE IF NOT EXISTS activities (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  start_date VARCHAR(10),
  end_date VARCHAR(10),
  status VARCHAR(20) DEFAULT 'draft',
  scoring_config TEXT DEFAULT '{"required":[],"elective":[]}',
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 队伍表
CREATE TABLE IF NOT EXISTS teams (
  id VARCHAR(64) PRIMARY KEY,
  activity_id VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_activity (activity_id),
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 成员表
CREATE TABLE IF NOT EXISTS members (
  id VARCHAR(64) PRIMARY KEY,
  team_id VARCHAR(64) NOT NULL,
  name VARCHAR(255) NOT NULL,
  title VARCHAR(100),
  status VARCHAR(20) DEFAULT 'active',
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_team (team_id),
  INDEX idx_status (status),
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 数据官表
CREATE TABLE IF NOT EXISTS data_officers (
  id VARCHAR(64) PRIMARY KEY,
  team_id VARCHAR(64) NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_team (team_id),
  INDEX idx_username (username),
  FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 每日记录表
CREATE TABLE IF NOT EXISTS daily_records (
  id VARCHAR(64) PRIMARY KEY,
  activity_id VARCHAR(64) NOT NULL,
  member_id VARCHAR(64) NOT NULL,
  date VARCHAR(10) NOT NULL,
  submissions TEXT DEFAULT '{}',
  submitted_by VARCHAR(64),
  confirmed TINYINT(1) DEFAULT 0,
  confirmed_by VARCHAR(64),
  confirmed_at INT,
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  UNIQUE KEY uk_record (activity_id, member_id, date),
  INDEX idx_member (member_id),
  INDEX idx_date (date),
  INDEX idx_confirmed (confirmed),
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE,
  FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 管理员表
CREATE TABLE IF NOT EXISTS admins (
  id VARCHAR(64) PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 备份记录表
CREATE TABLE IF NOT EXISTS backups (
  id VARCHAR(64) PRIMARY KEY,
  activity_id VARCHAR(64) NOT NULL,
  backup_date VARCHAR(10) NOT NULL,
  record_count INT DEFAULT 0,
  file_path VARCHAR(500),
  created_at INT DEFAULT (UNIX_TIMESTAMP()),
  INDEX idx_activity (activity_id),
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================== 初始数据 ====================

-- 插入默认管理员 (密码: admin123)
-- 密码哈希需要使用 bcrypt，实际部署时请更换
INSERT INTO admins (id, username, password_hash, created_at) VALUES
('admin_default', 'admin', '$2b$10$YourHashHere', UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE username = username;

-- 插入默认活动
INSERT INTO activities (id, name, start_date, end_date, status, scoring_config, created_at) VALUES
('activity_2024', '新人直播起号实战营', '5.18', '5.22', 'active',
 '{"required":[{"id":"hw1","name":"必修1：文字版输出课程感受+收获+行动","points":10},{"id":"hw2","name":"必修2：上播后台数据截图发送群中","points":10}],"elective":[{"id":"hw3","name":"选修1：朋友圈1条","points":20},{"id":"hw4","name":"选修2：演绎录制视频发圈打卡","points":20},{"id":"hw5","name":"选修3：直播转化报喜","points":20}]}',
 UNIX_TIMESTAMP())
ON DUPLICATE KEY UPDATE name = name;
