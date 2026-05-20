-- 1. store_type sütunundaki çoklu þirketleri ayýrýyoruz
WITH store_split AS (
    SELECT 
        master_id,
        TRIM(value) AS store,  -- Her bir þirket
        customer_value_total_ever_online,
        customer_value_total_ever_offline,
        order_num_total_ever_online,
        order_num_total_ever_offline
    FROM customers
    CROSS APPLY STRING_SPLIT(store_type, ',')
    WHERE store_type IS NOT NULL
),

-- 2. Þirket bazýnda toplamlarý ve ortalamalarý hesaplýyoruz
company_aggregate AS (
    SELECT
        store AS company,
        COUNT(DISTINCT master_id) AS musteri_sayisi,
        SUM(customer_value_total_ever_online) AS toplam_online_ciro,
        SUM(customer_value_total_ever_offline) AS toplam_offline_ciro,
        SUM(order_num_total_ever_online) AS toplam_online_siparis,
        SUM(order_num_total_ever_offline) AS toplam_offline_siparis
    FROM store_split
    GROUP BY store
),

-- 3. Online / offline yüzdelerini ve ortalama sepet tutarýný ekliyoruz
company_metrics AS (
    SELECT
        company,
        musteri_sayisi,
        toplam_online_ciro,
        toplam_offline_ciro,
        toplam_online_siparis,
        toplam_offline_siparis,
        ROUND(100.0 * toplam_online_ciro / NULLIF((toplam_online_ciro + toplam_offline_ciro),0), 2) AS online_ciro_yuzdesi,
        ROUND(100.0 * toplam_offline_ciro / NULLIF((toplam_online_ciro + toplam_offline_ciro),0), 2) AS offline_ciro_yuzdesi,
        ROUND(100.0 * toplam_online_siparis / NULLIF((toplam_online_siparis + toplam_offline_siparis),0), 2) AS online_siparis_yuzdesi,
        ROUND(100.0 * toplam_offline_siparis / NULLIF((toplam_online_siparis + toplam_offline_siparis),0), 2) AS offline_siparis_yuzdesi,
        ROUND(CASE WHEN toplam_online_siparis > 0 THEN toplam_online_ciro * 1.0 / toplam_online_siparis ELSE 0 END, 2) AS ortalama_online_siparis_basi_ciro,
        ROUND(CASE WHEN toplam_offline_siparis > 0 THEN toplam_offline_ciro * 1.0 / toplam_offline_siparis ELSE 0 END, 2) AS ortalama_offline_siparis_basi_ciro
    FROM company_aggregate
)

SELECT *
FROM company_metrics
ORDER BY toplam_online_ciro DESC;
