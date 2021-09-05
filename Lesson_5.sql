USE shop;

/* Задание 1: Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.*/

UPDATE users
	SET created_at = NOW() AND updated_at = NOW();
	
/* Задание 2: Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.*/

-- Удалим таблицу users и созданим новую, где столбцам created_at и updated_at применим тип VARCHAR
USE shop;
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  birthday_at DATE,
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
);

-- Заполним таблицу. Поля created_at и updated_at заполним датой в формат день/месяц/год
INSERT INTO users (name, birthday_at, created_at, updated_at) VALUES
	('Геннадий', '1991-10-05', '10.09.2021 15:10', '15.09.2021 18:10'),
	('Наталья', '1987-11-12', '17.01.2017 10:35', '12.09.2018 19:10'),
	('Александр', '1983-05-20', '05.03.2020 20:08', '13.10.2020 08:10'),
    ('Ермолай', '2000-02-14', '20.10.2018 18:49', '08.06.2019 15:10'),
    ('Клавдия', '1999-01-12', '28.04.1999 23:32', '25.11.2017 15:10'),
    ('Урсула', '1998-08-29', '12.07.2019 19:10', '10.09.2021 15:10');

-- Посмотрим, что получилось
SELECT * FROM users;

-- Заменим старый формат даты на новый
UPDATE users SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
	SET updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %l:%i');
	
-- Посмотрим, что получилось
SELECT * FROM users;

-- Если посмотрим на структуру таблицы, то увидим, что поля updated_at и created_at являются текстовыми 
DESCRIBE users;

-- Изменим тип данных в столбцах created_at и updated_at
ALTER TABLE users 
    CHANGE COLUMN `created_at` `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    CHANGE COLUMN `updated_at` `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
    
-- Посмотрим структуру таблицы
DESCRIBE users;

/* Задание 3: В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.*/

DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

-- Заполним таблицу данными
INSERT INTO
    storehouses_products (storehouse_id, product_id, value)
VALUES
    (1, 2, 0),
    (4, 7, 2500),
    (2, 3, 0),
    (1, 5, 30),
    (1, 9, 500);
    
-- Делаем сортировку данных с учётом условий задачи    
SELECT * FROM storehouses_products ORDER BY CASE WHEN value = 0 THEN TRUE ELSE FALSE END, value; 

/* Задание 4: Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')*/

SELECT
    id, name, birthday_at, 
    CASE 
        WHEN DATE_FORMAT(birthday_at, '%m') = 05 THEN 'may'
        WHEN DATE_FORMAT(birthday_at, '%m') = 08 THEN 'august'
    END AS month_birth
FROM
    users WHERE DATE_FORMAT(birthday_at, '%m') = 05 OR DATE_FORMAT(birthday_at, '%m') = 08;
    
    
-- Наверно, всё-же этот вариант будет правильнее, где в запросе месяц задан прописью
SELECT name, birthday_at FROM users WHERE MONTHNAME(birthday_at) IN ('may', 'august');
   
/* Задание 5: Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.*/

  SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIND_IN_SET(id,'5,1,2');
  
/* Практическое задание теме “Агрегация данных”*/

/* Задание 1: Подсчитайте средний возраст пользователей в таблице users*/

--Создадим столбец age, где вычислим возраст всех пользователей
ALTER TABLE users ADD age INT NOT NULL;

-- Делаем вычисления с помощью функции TIMESTAMPDIFF. В скобках указаны единица измерения, день рождения, сегодняшняя дата
UPDATE users SET age = TIMESTAMPDIFF(YEAR, birthday_at, NOW());
-- и ещё вариант
SELECT name, FLOOR((TO_DAYS(NOW()) - TO_DAYS(birthday_at)) / 365.25) AS age FROM users;

-- Посмотрим, что получилось
SELECT * FROM users;
  
-- Теперь вычислим средний возраст всех пользователей и выведем результат
SELECT AVG(age) FROM users;

/* Задание 2: Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.*/

-- Присвоим каждому дню недели номер
SELECT CASE WEEKDAY(birthday_at) WHEN 0 THEN 'Monday' WHEN 1 THEN 'Tuesday' WHEN 2 THEN 'Wednesday' WHEN 3 THEN 'Thursday' WHEN 4 THEN 'Friday' WHEN 5 THEN 'Saturday' WHEN 6 THEN 'Sunday' ELSE -1 END AS day_week, COUNT(birthday_at) AS number FROM users GROUP BY wd ORDER BY FIELD(wd,'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- Выведем конкатенированные данные с разделитилем в формате даты в столбцы day и total
SELECT DATE_FORMAT(DATE(CONCAT_WS('-', YEAR(NOW()), MONTH(birthday_at), DAY(birthday_at))), '%W') AS day, COUNT(*) AS total FROM users GROUP BY day ORDER BY total DESC;
  
/* Задание 3: Подсчитайте произведение чисел в столбце таблицы*/

-- Если я правильно поняла задание. Для примера возьмём таблицу storehouses_products
SELECT exp(sum(ln(value))) FROM storehouses_products; 

-- или пример: таблица users
SELECT exp(sum(ln(age))) FROM users;


