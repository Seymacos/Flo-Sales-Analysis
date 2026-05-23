WITH online_kanal AS (
    SELECT 
        order_channel AS cihaz,
        COUNT(master_id) AS musteri_sayisi,
        SUM(customer_value_total_ever_online) AS toplam_online_ciro,
        SUM(order_num_total_ever_online) AS toplam_online_siparis,
        SUM(customer_value_total_ever_online) * 1.0 / SUM(order_num_total_ever_online) AS ortalama_siparis_basi_ciro
    FROM customers
    WHERE order_num_total_ever_online > 0
    GROUP BY order_channel
),
toplam AS (
    SELECT
        SUM(toplam_online_ciro) AS genel_toplam_ciro,
        SUM(toplam_online_siparis) AS genel_toplam_siparis
    FROM online_kanal
)
SELECT 
    o.cihaz,
    o.musteri_sayisi,
    ROUND(o.toplam_online_ciro,2) AS toplam_online_ciro,
    ROUND(o.toplam_online_siparis,2) AS toplam_online_siparis,
    ROUND(o.toplam_online_ciro * 100.0 / t.genel_toplam_ciro,2) AS online_ciro_yuzdesi,
    ROUND(o.toplam_online_siparis * 100.0 / t.genel_toplam_siparis,2) AS online_siparis_yuzdesi,
    ROUND(o.ortalama_siparis_basi_ciro,2) AS ortalama_siparis_basi_ciro
FROM online_kanal o
CROSS JOIN toplam t
ORDER BY toplam_online_ciro DESC;
