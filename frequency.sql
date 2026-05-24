-- 3.2 Alýþveriþ Sýklýðý Analizi - KANAL BAZLI
WITH siklik_analizi AS (
    SELECT 
        master_id,
        order_num_total_ever_online,
        order_num_total_ever_offline,
        customer_value_total_ever_online,
        customer_value_total_ever_offline,
        (order_num_total_ever_online + order_num_total_ever_offline) as toplam_siparis,
        (customer_value_total_ever_online + customer_value_total_ever_offline) as toplam_deger,
        first_order_date,
        last_order_date,
        -- Kanal tercihi
        CASE 
            WHEN order_num_total_ever_online > 0 AND order_num_total_ever_offline = 0 THEN 'Sadece Online'
            WHEN order_num_total_ever_online = 0 AND order_num_total_ever_offline > 0 THEN 'Sadece Offline'  
            WHEN order_num_total_ever_online > 0 AND order_num_total_ever_offline > 0 THEN 'Omnichannel'
            ELSE 'Aktif Deðil'
        END as kanal_segmenti,
        -- Aylýk sipariþ sýklýðýný hesapla
        CASE 
            WHEN first_order_date IS NOT NULL AND last_order_date IS NOT NULL AND DATEDIFF(day, first_order_date, last_order_date) > 0
            THEN CAST((order_num_total_ever_online + order_num_total_ever_offline) AS FLOAT) * 30.0 / (DATEDIFF(day, first_order_date, last_order_date) + 1)
            WHEN (order_num_total_ever_online + order_num_total_ever_offline) = 1
            THEN 0 
            ELSE (order_num_total_ever_online + order_num_total_ever_offline) * 1.0 
        END as aylik_siparis_sikligi
    FROM customers
    WHERE (order_num_total_ever_online + order_num_total_ever_offline) > 0
)
SELECT 
    CASE 
        WHEN toplam_siparis = 1 THEN '1. Tek Alýþveriþ'
        WHEN aylik_siparis_sikligi <= 0.25 THEN '2. Çok Nadir (0-0.25/ay)'
        WHEN aylik_siparis_sikligi <= 0.5 THEN '3. Nadir (0.25-0.5/ay)'
        WHEN aylik_siparis_sikligi <= 1 THEN '4. Normal (0.5-1/ay)'
        WHEN aylik_siparis_sikligi <= 2 THEN '5. Sýk (1-2/ay)'
        ELSE '6. Çok Sýk (2+/ay)'
    END as siklik_grubu,
    kanal_segmenti,
    COUNT(*) as musteri_sayisi,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as yuzde_dagilim,
    -- TOPLAM DEÐERLER
    ROUND(AVG(toplam_deger), 2) as ortalama_toplam_deger,
    ROUND(SUM(toplam_deger), 2) as toplam_ciro,
    -- ONLINE DEÐERLER  
    ROUND(AVG(customer_value_total_ever_online), 2) as ortalama_online_deger,
    ROUND(SUM(customer_value_total_ever_online), 2) as toplam_online_ciro,
    ROUND(AVG(order_num_total_ever_online), 1) as ortalama_online_siparis,
    -- OFFLINE DEÐERLER
    ROUND(AVG(customer_value_total_ever_offline), 2) as ortalama_offline_deger, 
    ROUND(SUM(customer_value_total_ever_offline), 2) as toplam_offline_ciro,
    ROUND(AVG(order_num_total_ever_offline), 1) as ortalama_offline_siparis,
    -- GENEL
    ROUND(AVG(toplam_siparis), 1) as ortalama_toplam_siparis,
    ROUND(AVG(aylik_siparis_sikligi), 2) as ortalama_aylik_siklik
FROM siklik_analizi
GROUP BY 
    CASE 
        WHEN toplam_siparis = 1 THEN '1. Tek Alýþveriþ'
        WHEN aylik_siparis_sikligi <= 0.25 THEN '2. Çok Nadir (0-0.25/ay)'
        WHEN aylik_siparis_sikligi <= 0.5 THEN '3. Nadir (0.25-0.5/ay)'
        WHEN aylik_siparis_sikligi <= 1 THEN '4. Normal (0.5-1/ay)'
        WHEN aylik_siparis_sikligi <= 2 THEN '5. Sýk (1-2/ay)'
        ELSE '6. Çok Sýk (2+/ay)'
    END,
    kanal_segmenti
ORDER BY ortalama_toplam_deger DESC;