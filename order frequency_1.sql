SELECT
    alýþveriþ_sýklýðý_segmenti,
    COUNT(master_id) AS müþteri_sayýsý,
    AVG(gün_sayýsý_ilk_ve_son_alisveris) AS ortalama_gün_sayýsý,
    AVG(toplam_alisveris_sayýsý) AS ortalama_alisveris,
    AVG(toplam_harcama) AS ortalama_harcama
FROM (
    SELECT
        master_id,
        first_order_date AS ilk_alisveris_tarihi,
        last_order_date AS son_alisveris_tarihi,
        DATEDIFF(DAY, first_order_date, last_order_date) AS gün_sayýsý_ilk_ve_son_alisveris,
        order_num_total_ever_online + order_num_total_ever_offline AS toplam_alisveris_sayýsý,
        customer_value_total_ever_online + customer_value_total_ever_offline AS toplam_harcama,
        CASE 
            WHEN DATEDIFF(DAY, first_order_date, last_order_date) = 0 THEN 'Tek Gün Alýþveriþi'
            WHEN (order_num_total_ever_online + order_num_total_ever_offline) / NULLIF(DATEDIFF(DAY, first_order_date, last_order_date), 0) > 0.5 THEN 'Sýk Alýþveriþ'
            WHEN (order_num_total_ever_online + order_num_total_ever_offline) / NULLIF(DATEDIFF(DAY, first_order_date, last_order_date), 0) BETWEEN 0.1 AND 0.5 THEN 'Düzenli Alýþveriþ'
            ELSE 'Nadir Alýþveriþ'
        END AS alýþveriþ_sýklýðý_segmenti
    FROM
        customers
) AS alt_sorgu
GROUP BY
    alýþveriþ_sýklýðý_segmenti
ORDER BY
    müþteri_sayýsý DESC;







