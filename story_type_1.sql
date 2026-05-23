-- A, B veya A,B hangi store type daha deðerli? (Yüzdeli)
SELECT 
    store_type AS magaza_tipi,
    COUNT(master_id) AS musteri_sayisi,
    FORMAT(COUNT(master_id) * 100.0 / SUM(COUNT(master_id)) OVER(), 'N2') AS musteri_yuzde,
    ROUND(SUM(customer_value_total_ever_online + customer_value_total_ever_offline), 2) AS toplam_gelir,
    ROUND(SUM(customer_value_total_ever_online + customer_value_total_ever_offline) * 100.0 / 
          SUM(SUM(customer_value_total_ever_online + customer_value_total_ever_offline)) OVER(), 2) AS gelir_yuzde,
    ROUND(AVG(customer_value_total_ever_online + customer_value_total_ever_offline), 2) AS ortalama_musteri_degeri,
    ROUND(AVG(order_num_total_ever_online + order_num_total_ever_offline), 2) AS ortalama_siparis_sayisi
FROM customers
GROUP BY store_type
ORDER BY toplam_gelir DESC;