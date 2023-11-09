--- 09-11-2023 20:09:36
--- No.1 Please create dimension tables dim_user , dim_post , and dim_date to store
normalized data from the raw tables
Jawab:
CREATE DIMENSION dim_user (
  user_id INT NOT NULL,
  user_name VARCHAR(255) NOT NULL,
  country VARCHAR(255) NOT NULL,
  PRIMARY KEY (user_id)
);

CREATE DIMENSION dim_post (
  post_id INT NOT NULL,
  post_text VARCHAR(255) NOT NULL,
  post_date DATE NOT NULL,
  user_id INT NOT NULL,
  PRIMARY KEY (post_id),
  FOREIGN KEY (user_id) REFERENCES dim_user (user_id)
);

CREATE DIMENSION dim_date (
  date_id INT NOT NULL,
  date DATE NOT NULL,
  PRIMARY KEY (date_id)
);


--- 09-11-2023 20:10:08
--- No.2 Populate the dimension tables by inserting data from the related raw tables
Jawab:
INSERT INTO dim_user (user_id, user_name, country)
SELECT user_id, user_name, country
FROM raw_users;

INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT post_id, post_text, post_date, user_id
FROM raw_posts;

INSERT INTO dim_date (date_id, date)
SELECT date_id, post_date
FROM raw_posts;


--- 09-11-2023 20:10:24
--- No.3 Create a fact table called fact_post_performance to store metrics like post views and
likes over time
Jawab:
CREATE FACT TABLE fact_post_performance (
  post_id INT NOT NULL,
  date_id INT NOT NULL,
  post_views INT NOT NULL,
  post_likes INT NOT NULL,
  PRIMARY KEY (post_id, date_id),
  FOREIGN KEY (post_id) REFERENCES dim_post (post_id),
  FOREIGN KEY (date_id) REFERENCES dim_date (date_id)
);


--- 09-11-2023 20:10:35
--- No.4 Populate the fact table by joining and aggregating data from the raw tables
Jawab:
INSERT INTO fact_post_performance (post_id, date_id, post_views, post_likes)
SELECT post_id, date_id, COUNT(DISTINCT user_id), COUNT(*)
FROM raw_likes
GROUP BY post_id, date_id;


--- 09-11-2023 20:10:48
--- No.5 Please create a fact_daily_posts table to capture the number of posts per user per
day
Jawab
CREATE FACT TABLE fact_daily_posts (
  user_id INT NOT NULL,
  date_id INT NOT NULL,
  num_posts INT NOT NULL,
  PRIMARY KEY (user_id, date_id),
  FOREIGN KEY (user_id) REFERENCES dim_user (user_id),
  FOREIGN KEY (date_id) REFERENCES dim_date (date_id)
);


--- 09-11-2023 20:11:01
--- No.6 Also populate the fact table by joining and aggregating data from the raw tables
Jawab:
INSERT INTO fact_daily_posts (user_id, date_id, num_posts)
SELECT user_id, post_date, COUNT(*)
FROM raw_posts
GROUP BY user_id, post_date;

