WITH frekans_seg AS (
    SELECT
        master_id,
        (order_num_total_ever_online + order_num_total_ever_offline) AS toplam_siparis,
        (customer_value_total_ever_online + customer_value_total_ever_offline) AS toplam_ciro
    FROM customers
),
gruplama AS (
    SELECT
        master_id,
        toplam_siparis,
        toplam_ciro,
        CASE
            WHEN toplam_siparis BETWEEN 1 AND 2 THEN '1-2 Az Sipariþ'
            WHEN toplam_siparis BETWEEN 3 AND 5 THEN '3-5 Orta Sipariþ'
            WHEN toplam_siparis > 5 THEN '5- Çok Sipariþ'
            ELSE 'Hiç Sipariþ Yok'
        END AS siparis_segmenti
    FROM frekans_seg
)
SELECT
    siparis_segmenti,
    COUNT(master_id) AS musteri_sayisi,
    SUM(toplam_ciro) AS toplam_ciro,
    SUM(toplam_siparis) AS toplam_siparis,
    ROUND(SUM(toplam_ciro) * 1.0 / NULLIF(SUM(toplam_siparis),0),2) AS ortalama_siparis_basi_ciro
FROM gruplama
GROUP BY siparis_segmenti
ORDER BY siparis_segmenti;



WITH frekans_seg AS (
    SELECT
        master_id,
        order_num_total_ever_online,
        order_num_total_ever_offline,
        customer_value_total_ever_online,
        customer_value_total_ever_offline,
        (order_num_total_ever_online + order_num_total_ever_offline) AS toplam_siparis,
        (customer_value_total_ever_online + customer_value_total_ever_offline) AS toplam_ciro
    FROM customers
),
gruplama AS (
    SELECT
        master_id,
        toplam_siparis,
        toplam_ciro,
        order_num_total_ever_online,
        order_num_total_ever_offline,
        customer_value_total_ever_online,
        customer_value_total_ever_offline,
        CASE
            WHEN toplam_siparis BETWEEN 1 AND 2 THEN '1-2 Az Sipariþ'
            WHEN toplam_siparis BETWEEN 3 AND 5 THEN '3-5 Orta Sipariþ'
            WHEN toplam_siparis > 5 THEN '5- Çok Sipariþ'
            ELSE 'Hiç Sipariþ Yok'
        END AS siparis_segmenti
    FROM frekans_seg
)
SELECT
    siparis_segmenti,
    COUNT(master_id) AS musteri_sayisi,
    
    -- Toplam ciro ve sipariþ sayýsý
    SUM(customer_value_total_ever_online) AS toplam_online_ciro,
    SUM(order_num_total_ever_online) AS toplam_online_siparis,
    ROUND(SUM(customer_value_total_ever_online) * 1.0 / NULLIF(SUM(order_num_total_ever_online),0),2) AS ortalama_online_siparis_basi_ciro,
    
    SUM(customer_value_total_ever_offline) AS toplam_offline_ciro,
    SUM(order_num_total_ever_offline) AS toplam_offline_siparis,
    ROUND(SUM(customer_value_total_ever_offline) * 1.0 / NULLIF(SUM(order_num_total_ever_offline),0),2) AS ortalama_offline_siparis_basi_ciro
    
FROM gruplama
GROUP BY siparis_segmenti
ORDER BY siparis_segmenti;
