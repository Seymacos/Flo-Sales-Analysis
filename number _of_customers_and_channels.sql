WITH kanal_verisi AS (
    SELECT
        master_id,
        -- Müþteri segmentasyonu: sadece online, sadece offline veya her ikisi (omnichannel)
        CASE 
            WHEN order_num_total_ever_online > 0 AND order_num_total_ever_offline = 0 THEN 'Sadece Online'
            WHEN order_num_total_ever_offline > 0 AND order_num_total_ever_online = 0 THEN 'Sadece Offline'
            WHEN order_num_total_ever_online > 0 AND order_num_total_ever_offline > 0 THEN 'Omnichannel'
            ELSE 'Bilinmiyor'
        END AS segment,
        
        customer_value_total_ever_online, -- Online toplam harcama
        customer_value_total_ever_offline, -- Offline toplam harcama
        order_num_total_ever_online, -- Online toplam sipariþ sayýsý
        order_num_total_ever_offline -- Offline toplam sipariþ sayýsý
    FROM customers
),
agregasyon AS (
    SELECT 
        segment,
        COUNT(master_id) AS musteri_sayisi, -- Segmentteki toplam müþteri sayýsý
        SUM(order_num_total_ever_online) AS toplam_online_siparis,
        SUM(order_num_total_ever_offline) AS toplam_offline_siparis,
        SUM(customer_value_total_ever_online) AS toplam_online_ciro,
        SUM(customer_value_total_ever_offline) AS toplam_offline_ciro,
        AVG(customer_value_total_ever_online) AS ortalama_online_musteri_harcama,
        AVG(customer_value_total_ever_offline) AS ortalama_offline_musteri_harcama,
        AVG(CASE WHEN order_num_total_ever_online > 0 
                 THEN customer_value_total_ever_online / order_num_total_ever_online 
                 ELSE NULL END) AS ortalama_online_sepet_tutari,
        AVG(CASE WHEN order_num_total_ever_offline > 0
                 THEN customer_value_total_ever_offline / order_num_total_ever_offline
                 ELSE NULL END) AS ortalama_offline_sepet_tutari
    FROM kanal_verisi
    GROUP BY segment
),
toplamlar AS (
    -- Toplam sipariþ ve toplam ciro, yüzdeleri hesaplamak için
    SELECT
        SUM(toplam_online_siparis) AS toplam_online_siparis,
        SUM(toplam_offline_siparis) AS toplam_offline_siparis,
        SUM(toplam_online_ciro) AS toplam_online_ciro,
        SUM(toplam_offline_ciro) AS toplam_offline_ciro
    FROM agregasyon
)
SELECT 
    a.segment AS Musteri_Segmenti,
    a.musteri_sayisi AS Musteri_Sayisi,
    a.toplam_online_siparis AS Toplam_Online_Siparis,
    a.toplam_offline_siparis AS Toplam_Offline_Siparis,
    ROUND(100.0 * a.toplam_online_siparis / (t.toplam_online_siparis + t.toplam_offline_siparis),2) AS Online_Siparis_Yuzdesi,
    ROUND(100.0 * a.toplam_offline_siparis / (t.toplam_online_siparis + t.toplam_offline_siparis),2) AS Offline_Siparis_Yuzdesi,
    ROUND(a.toplam_online_ciro, 2) AS Toplam_Online_Tutar,
    ROUND(a.toplam_offline_ciro, 2) AS Toplam_Offline_Tutar,
    ROUND(100.0 * a.toplam_online_ciro / (t.toplam_online_ciro + t.toplam_offline_ciro),2) AS Online_Ciro_Yuzdesi,
    ROUND(100.0 * a.toplam_offline_ciro / (t.toplam_online_ciro + t.toplam_offline_ciro),2) AS Offline_Ciro_Yuzdesi,
    ROUND(a.ortalama_online_musteri_harcama, 2) AS Ortalama_Online_Harcama,
    ROUND(a.ortalama_offline_musteri_harcama, 2) AS Ortalama_Offline_Harcama,
    ROUND(a.ortalama_online_sepet_tutari, 2) AS Ortalama_Online_Sepet_Tutari,
    ROUND(a.ortalama_offline_sepet_tutari, 2) AS Ortalama_Offline_Sepet_Tutari
FROM agregasyon a
CROSS JOIN toplamlar t
ORDER BY Musteri_Segmenti;
