#standardSQL
SELECT
  ds,
  cookcieID,
  countIF(viewersLanding=1) AS viewersLanding,
  countIF(ConversionPage=1 AND viewersLanding=1) AS ConversionPage
FROM (
  SELECT
    clientId,
    REGEXP_EXTRACT(cd.value, r'{cookie default="cookcieID" type="input"}.\d+.(\d+)') AS cookcieID,
    FORMAT_DATE("%Y%m%d", DATE(TIMESTAMP_SECONDS(timestamp))) AS ds,
    IF(countIF(page.pagePath like '%landing/step1%')=0,0,1) AS viewersLanding,
    IF(countIF(page.pagePath like '%ConversionPage%')=0,0,1) AS ConversionPage
  FROM
    bigdata.ga, unNEST(customDimensions) AS cd
  WHERE
    _PARTITIONTIME BETWEEN TIMESTAMP('{dateFrom default="2018-05-04" type="datetime"}')
    AND TIMESTAMP('{dateTo default="2018-05-10" type="datetime"}')
    AND cd.index=18
    AND cd.value LIKE '%{cookie default="cookcieID" type="input"}%'
  GROUP BY 1, 2, 3)
GROUP BY 1, 2
ORDER BY 1