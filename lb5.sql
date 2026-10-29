USE medicines2;
-- 1. Добавить внешние ключи.
ALTER TABLE dealer
ADD CONSTRAINT FK_dealer_company FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE production
ADD CONSTRAINT FK_production_company FOREIGN KEY (id_company) REFERENCES company(id_company),
ADD CONSTRAINT FK_production_medicine FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);

ALTER TABLE `order`
ADD CONSTRAINT FK_order_production FOREIGN KEY (id_production) REFERENCES production(id_production),
ADD CONSTRAINT FK_order_dealer FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer),
ADD CONSTRAINT FK_order_pharmacy FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);


-- 2. Выдать информацию по всем заказам лекарствам "Кордерон" компании "Аргус" с указанием названий аптек, дат, объема заказов.
SELECT 
    pharmacy.name AS pharmacy_name, 
    `order`.date AS order_date, 
    `order`.quantity AS order_quantity
FROM `order`
JOIN production ON `order`.id_production = production.id_production
JOIN medicine ON production.id_medicine = medicine.id_medicine
JOIN company ON production.id_company = company.id_company
JOIN pharmacy ON `order`.id_pharmacy = pharmacy.id_pharmacy
WHERE medicine.name = 'Кордерон' AND company.name = 'Аргус';


-- 3. Дать список лекарств компании "Фарма", на которые не были сделаны заказы до 25 января.
SELECT DISTINCT medicine.name
FROM medicine
JOIN production ON medicine.id_medicine = production.id_medicine
JOIN company ON production.id_company = company.id_company
LEFT JOIN `order` ON production.id_production = `order`.id_production AND `order`.date < '2019-01-25'
WHERE company.name = 'Фарма' AND `order`.id_order IS NULL;


-- 4. Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT 
    company.name AS company_name, 
    MIN(production.rating) AS min_rating, 
    MAX(production.rating) AS max_rating
FROM company
JOIN production ON company.id_company = production.id_company
JOIN `order` ON production.id_production = `order`.id_production
GROUP BY company.id_company, company.name
HAVING COUNT(`order`.id_order) >= 120;


-- 5. Дать списки сделавших заказы аптек по всем дилерам компании "AstraZeneca". Если у дилера нет заказов, в названии аптеки проставить NULL.
SELECT 
    dealer.name AS dealer_name, 
    pharmacy.name AS pharmacy_name
FROM dealer
LEFT JOIN `order` ON dealer.id_dealer = `order`.id_dealer
LEFT JOIN pharmacy ON `order`.id_pharmacy = pharmacy.id_pharmacy
WHERE dealer.id_company = (SELECT id_company FROM company WHERE name = 'AstraZeneca');


-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.
UPDATE production
JOIN medicine ON production.id_medicine = medicine.id_medicine
SET production.price = production.price * 0.8
WHERE production.price > 3000 AND medicine.cure_duration <= 7;


-- 7. Добавить необходимые индексы.
CREATE INDEX `IX_production_id-company_id-medicine` ON production (id_company, id_medicine);
CREATE INDEX `IX_order_id-production_date` ON `order` (id_production, date); 
CREATE INDEX `IX_dealer_id-company` ON dealer (id_company);
CREATE INDEX `IX_order_id-dealer` ON `order` (id_dealer);
CREATE INDEX `IX_order_id-pharmacy` ON `order` (id_pharmacy);
CREATE INDEX `IX_medicine_name` ON medicine (name(255));
CREATE INDEX `IX_company_name` ON company (name(255));
CREATE INDEX `IX_pharmacy_name` ON pharmacy (name(255));