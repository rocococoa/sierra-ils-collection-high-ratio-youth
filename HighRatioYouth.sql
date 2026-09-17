/* Retrieves a list of youth print titles that have a 2:1 hold ratio or more
   OR have holds but 0 holdable items. 
   Created AGW 4/2026 */
   
WITH hold_counts AS (
    SELECT
        h.record_id AS bib_record_id,
        COUNT(h.id) AS hold_count,
		COUNT(*) FILTER (WHERE h.is_frozen = true) AS hold_frozen
    FROM
        sierra_view.hold h
    GROUP BY
        h.record_id
),

item_stats AS (
    SELECT 
        bri.bib_record_id,
        COUNT(i.id) FILTER (
            WHERE i.item_status_code NOT IN ('$', 'n', 'w', 'm')
            AND i.location_code NOT IN ('mfolb', 'mfold', 'bfol','bfolx', 'mjbin')
        ) AS item_totals,
        COUNT(i.id) FILTER (
            WHERE i.item_status_code NOT IN ('$', 'n', 'w', 'm')
            AND i.location_code IN ('mfolb', 'mfold', 'bfol','bfolx', 'mjbin')
        ) AS non_hold_item_totals
    FROM sierra_view.item_record i 
    JOIN sierra_view.bib_record_item_record_link bri ON i.id = bri.item_record_id
    GROUP BY bri.bib_record_id
),

outstanding_orders AS (
    SELECT 
        bro.bib_record_id,
        COUNT(DISTINCT o.id) AS order_count
    FROM sierra_view.order_record o 
    JOIN sierra_view.bib_record_order_record_link bro ON o.id = bro.order_record_id
    WHERE o.order_status_code = 'o'
    GROUP BY bro.bib_record_id
), 

billed_items AS (SELECT
	bri.bib_record_id AS "record_id",
	i.year_to_date_checkout_total AS "ytd_circ", 
	i.last_year_to_date_checkout_total AS "lycirc", 
	i.last_status_update::date AS "date_billed"
    
    
FROM
    sierra_view.item_view i
JOIN sierra_view.record_metadata rmi ON rmi.id = i.id AND rmi.record_type_code = 'i'
JOIN sierra_view.bib_record_item_record_link bri ON bri.item_record_id = i.id
JOIN sierra_view.record_metadata rmb ON rmb.id = bri.bib_record_id AND rmb.record_type_code = 'b'
JOIN sierra_view.phrase_entry peb ON peb.record_id = bri.bib_record_id AND peb.index_tag = 'c'
LEFT JOIN sierra_view.phrase_entry pei ON pei.record_id = i.id AND pei.index_tag = 'c'
JOIN sierra_view.bib_record_property brp ON brp.bib_record_id = bri.bib_record_id

WHERE
    i.item_status_code = 'n'
)

SELECT
    UPPER(peb.index_entry) AS "Call#",
    brp.best_author AS "Author",
    brp.best_title AS "Title",
    COALESCE(hc.hold_count, 0) AS "Holds",
	COALESCE(hc.hold_frozen, 0) AS "Frozen holds",
    COALESCE(its.item_totals, 0) AS "Holdable Items",
    COALESCE(its.non_hold_item_totals, 0) AS "Non-Holdable Items",
    COALESCE(oo.order_count, 0) AS "Outstanding Orders",
    CASE 
        WHEN COALESCE(its.item_totals, 0) = 0 THEN hc.hold_count::numeric 
        ELSE ROUND(hc.hold_count::numeric / its.item_totals, 1) 
    END AS "Ratio",
    'b' || rmb.record_num || 'a' AS "Bib Record Num",
	brp.publish_year AS "Pub Year",
		CASE 
    	WHEN bi.date_billed IS NULL THEN 'n/a' 
    	ELSE bi.date_billed::TEXT 
	END AS "Date Billed",
		CASE 
    	WHEN bi.ytd_circ IS NULL THEN 'n/a' 
    	ELSE bi.ytd_circ::TEXT 
	END AS "YTD Circ",
		CASE 
	    WHEN bi.lycirc IS NULL THEN 'n/a' 
    	ELSE bi.lycirc::TEXT 
	END AS "LY Circ"

FROM
    sierra_view.bib_record_property brp
JOIN sierra_view.record_metadata rmb ON rmb.id = brp.bib_record_id
LEFT JOIN sierra_view.phrase_entry peb ON peb.record_id = brp.bib_record_id AND peb.index_tag = 'c'
LEFT JOIN hold_counts hc ON hc.bib_record_id = brp.bib_record_id
LEFT JOIN item_stats its ON its.bib_record_id = brp.bib_record_id
LEFT JOIN outstanding_orders oo ON oo.bib_record_id = brp.bib_record_id
LEFT JOIN billed_items bi ON bi.record_id = rmb.id
WHERE
    (
        (hc.hold_count::numeric / NULLIF(its.item_totals, 0) >= 2)
        OR 
        (COALESCE(its.item_totals, 0) = 0 AND hc.hold_count >= 1)
    )
    AND brp.material_code IN ('cbb', 'cef', 'cf', 'cff', 'cgn', 'cnf', 'cpi', 'cla', 'yf', 'ygn', 'ynf')
ORDER BY
    "Call#",
    brp.best_author,
	"Ratio" DESC
	;