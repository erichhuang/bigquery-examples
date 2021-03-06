# Count the number of variants across the entirety of 1,000 Genomes by variant type.
SELECT
  vt,
  COUNT(vt) as cnt,
FROM
  [google.com:biggene:1000genomes.variants1kG]
GROUP BY
  vt
ORDER BY
  vt;
