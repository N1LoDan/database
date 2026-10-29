USE computer_configuration;
-- =====================================================
-- 3.1 INSERT
-- =====================================================

/* a. Без указания списка полей */
INSERT INTO hardware_category 
VALUES (NULL, 'Материнская плата', 'MB', 'Материнские платы для ПК', DEFAULT);

/* b. С указанием списка полей */
INSERT INTO manufacturer (manufacturer_name, country, website, support_email) 
VALUES ('NVIDIA', 'USA', 'https://www.nvidia.com', 'support@nvidia.com');

/* c. С чтением значения из другой таблицы */
INSERT INTO manufacturer (manufacturer_name, country, website, support_email) 
SELECT 'AMD Clone', country, website, support_email 
FROM manufacturer 
WHERE manufacturer_name = 'AMD';


-- =====================================================
-- 3.2. DELETE
-- =====================================================

/* a. Всех записей (очистка таблицы связей) */
DELETE FROM configuration_hardware;

/* b. По условию */
DELETE FROM hardware 
WHERE price < 1000 AND hardware_category_id = 2;


-- =====================================================
-- 3.3. UPDATE
-- =====================================================

/* a. Всех записей (плановое повышение цен на все комплектующие на 5%) */
UPDATE hardware 
SET price = price * 1.05;

/* b. По условию обновляя один атрибут */
UPDATE computer 
SET price = 65000.00 
WHERE computer_name = 'ThinkCentre Neo 50s';

/* c. По условию обновляя несколько атрибутов */
UPDATE manufacturer 
SET country = 'China', support_email = 'help@lenovo.cn' 
WHERE manufacturer_name = 'Lenovo';


-- =====================================================
-- 3.4. SELECT
-- =====================================================

/* a. С набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...) */
SELECT hardware_name, price 
FROM hardware;

/* b. Со всеми атрибутами (SELECT * FROM...) */
SELECT * 
FROM computer;

/* c. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = value) */
SELECT * 
FROM manufacturer 
WHERE country = 'USA';


-- =====================================================
-- 3.5. SELECT ORDER BY + LIMIT (вместо TOP)
-- =====================================================

/* a. С сортировкой по возрастанию ASC + ограничение вывода количества записей */
SELECT hardware_name, price 
FROM hardware 
ORDER BY price ASC 
LIMIT 5;

/* b. С сортировкой по убыванию DESC */
SELECT computer_name, price 
FROM computer 
ORDER BY price DESC 
LIMIT 3;

/* c. С сортировкой по двум атрибутам + ограничение вывода количества записей */
SELECT hardware_name, hardware_category_id, price 
FROM hardware 
ORDER BY hardware_category_id ASC, price DESC 
LIMIT 10;

/* d. С сортировкой по первому атрибуту, из списка извлекаемых (цифра 1 ссылается на hardware_name) */
SELECT hardware_name, price 
FROM hardware 
ORDER BY 1 ASC 
LIMIT 5;


-- =====================================================
-- 3.6. Работа с датами (используется поле created_at типа TIMESTAMP/DATETIME)
-- =====================================================

/* a. WHERE по дате */
SELECT computer_name, created_at 
FROM computer 
WHERE DATE(created_at) = '2024-02-10';

/* b. WHERE дата в диапазоне */
SELECT computer_name, created_at 
FROM computer 
WHERE created_at BETWEEN '2024-01-01 00:00:00' AND '2024-12-31 23:59:59';

/* c. Извлечь из таблицы не всю дату, а только год. Используется функция YEAR() */
SELECT computer_name, YEAR(created_at) AS creation_year 
FROM computer;


-- =====================================================
-- 3.7. Функции агрегации
-- =====================================================

/* a. Посчитать количество записей в таблице */
SELECT COUNT(*) AS total_computers 
FROM computer;

/* b. Посчитать количество уникальных записей в таблице (уникальных производителей железа) */
SELECT COUNT(DISTINCT manufacturer_id) AS unique_manufacturers 
FROM hardware;

/* c. Вывести уникальные значения столбца */
SELECT DISTINCT country 
FROM manufacturer;

/* d. Найти максимальное значение столбца */
SELECT MAX(price) AS max_hardware_price 
FROM hardware;

/* e. Найти минимальное значение столбца */
SELECT MIN(price) AS min_hardware_price 
FROM hardware;

/* f. Написать запрос COUNT() + GROUP BY */
SELECT hardware_category_id, COUNT(*) AS items_count 
FROM hardware 
GROUP BY hardware_category_id;


-- =====================================================
-- 3.8. SELECT GROUP BY + HAVING
-- =====================================================

/* 
Запрос 1: 
Запрос находит ID производителей, у которых в каталоге зарегистрировано более одного комплектующего. 
Это полезно для понимания того, кто является массовым поставщиком, а кто представлен единичными товарами.
*/
SELECT manufacturer_id, COUNT(*) AS hardware_count 
FROM hardware 
GROUP BY manufacturer_id 
HAVING hardware_count > 1;

/* 
Запрос 2: 
Запрос находит ID комплектаций, суммарная стоимость компонентов в которых превышает 50 000. 
Помогает выделить премиальные или серверные сборки среди всех доступных.
*/
SELECT configuration_id, SUM(unit_price * quantity) AS total_cost 
FROM configuration_hardware 
GROUP BY configuration_id 
HAVING total_cost > 50000;

/* 
Запрос 3: 
Запрос находит ID базовых моделей компьютеров, для которых создано 2 или более вариантов комплектации. 
Полезно для анализа гибкости модельного ряда.
*/
SELECT computer_id, COUNT(configuration_id) AS config_count 
FROM configuration 
GROUP BY computer_id 
HAVING config_count >= 2;


-- =====================================================
-- 3.9. SELECT JOIN
-- =====================================================

/* a. LEFT JOIN двух таблиц и WHERE по одному из атрибутов */
SELECT m.manufacturer_name, h.hardware_name 
FROM manufacturer m 
LEFT JOIN hardware h ON m.manufacturer_id = h.manufacturer_id 
WHERE m.country = 'USA';

/* b. RIGHT JOIN. Получить такую же выборку, как и в 3.9 a (меняем таблицы местами) */
SELECT m.manufacturer_name, h.hardware_name 
FROM hardware h 
RIGHT JOIN manufacturer m ON h.manufacturer_id = m.manufacturer_id 
WHERE m.country = 'USA';

/* c. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы */
SELECT m.manufacturer_name, hc.category_name, h.hardware_name 
FROM manufacturer m 
LEFT JOIN hardware h ON m.manufacturer_id = h.manufacturer_id 
LEFT JOIN hardware_category hc ON h.hardware_category_id = hc.hardware_category_id 
WHERE m.country = 'USA' 
  AND hc.is_active = TRUE 
  AND h.price > 10000;

/* d. INNER JOIN двух таблиц */
SELECT c.computer_name, cfg.configuration_name 
FROM computer c 
INNER JOIN configuration cfg ON c.computer_id = cfg.computer_id;


-- =====================================================
-- 3.10. Подзапросы
-- =====================================================

/* a. Написать запрос с условием WHERE IN (подзапрос). Найти железо от американских производителей. */
SELECT hardware_name, price 
FROM hardware 
WHERE manufacturer_id IN (
    SELECT manufacturer_id 
    FROM manufacturer 
    WHERE country = 'USA'
);

/* b. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ... Вывести цену каждого комплектующего и среднюю по рынку */
SELECT 
    hardware_name, 
    price, 
    (SELECT AVG(price) FROM hardware) AS avg_market_price 
FROM hardware;

/* c. Написать запрос вида SELECT * FROM (подзапрос). Выборка из виртуальной таблицы американских брендов */
SELECT * 
FROM (
    SELECT manufacturer_name, country 
    FROM manufacturer 
    WHERE country = 'USA'
) AS usa_brands;

/* d. Написать запрос вида SELECT * FROM table JOIN (подзапрос) ON …. Вывести названия компьютеров и количество созданных для них комплектаций */
SELECT c.computer_name, stats.configs_count 
FROM computer c 
JOIN (
    SELECT computer_id, COUNT(*) AS configs_count 
    FROM configuration 
    GROUP BY computer_id
) AS stats ON c.computer_id = stats.computer_id;