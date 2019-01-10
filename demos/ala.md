<!--
author:   Your Name

email:    your@mail.org

version:  0.0.1

language: en

narrator: US English Female

comment:  Try to write a short comment about
          your course, multiline is also okay.

script:   https://cdnjs.cloudflare.com/ajax/libs/alasql/0.4.11/alasql-worker.min.js
          https://cdnjs.cloudflare.com/ajax/libs/alasql/0.4.11/alasql.min.js


script:  https://cdnjs.cloudflare.com/ajax/libs/PapaParse/4.6.1/papaparse.min.js

@eval
<script>
try {
  JSON.stringify(alasql(`@input`), null, 3);
} catch(e) {
  let error = new LiaError(e.message, 1);
  try {
    let log = e.message.match(/.*line (\d):.*\n.*\n.*\n(.*)/);
    error.add_detail(0, e.name+": "+log[2], "error", log[1] -1 , 0);
  } catch(e) {}
  throw error ;
}
</script>
@end


@eval_with_csv
<script>
let data = Papa.parse(`@input(1)`, {header: true});

let error = "";
if(data.errors.length != 0) {
    error = JSON.stringify(data.errors, null, 3)+"\n";
}

try {
  error += JSON.stringify(alasql(`@input`, [data.data]), null, 3);
} catch(e) {
  let error = new LiaError(e.message, 1);
  try {
    let log = e.message.match(/.*line (\d):.*\n.*\n.*\n(.*)/);
    error.add_detail(0, e.name+": "+log[2], "error", log[1] -1 , 0);
  } catch(e) {}
  throw error ;
}
</script>
@end

-->

# AlaSQL template

This is a quick and clean template for using AlaSQL within LiaScript.


## Example

``` sql
CREATE TABLE test (language INT, hello STRING);

-- insert dummy values
INSERT INTO test VALUES (1,'Hello!');
INSERT INTO test VALUES (2,'Aloha!');
INSERT INTO test VALUES (3,'Bonjour!');

SELECT * FROM test WHERE language > 1;
```
@eval



``` sql
/*
select some stuff
*/
SELECT * FROM test WHERE language > 1;
```
@eval


## Reading CSV


``` sql
CREATE TABLE one;

-- ? gets replaced by the values in data.csv
INSERT INTO one SELECT * from ?;
```
``` text -data.csv
Region,Country,Item Type,Sales Channel,Order Priority,Order Date,Order ID,Ship Date,Units Sold,Unit Price,Unit Cost,Total Revenue,Total Cost,Total Profit
Middle East and North Africa,Libya,Cosmetics,Offline,M,10/18/2014,686800706,10/31/2014,8446,437.20,263.33,3692591.20,2224085.18,1468506.02
North America,Canada,Vegetables,Online,M,11/7/2011,185941302,12/8/2011,3018,154.06,90.93,464953.08,274426.74,190526.34
Middle East and North Africa,Libya,Baby Food,Offline,C,10/31/2016,246222341,12/9/2016,1517,255.28,159.42,387259.76,241840.14,145419.62
Asia,Japan,Cereal,Offline,C,4/10/2010,161442649,5/12/2010,3322,205.70,117.11,683335.40,389039.42,294295.98
Sub-Saharan Africa,Chad,Fruits,Offline,H,8/16/2011,645713555,8/31/2011,9845,9.33,6.92,91853.85,68127.40,23726.45
Europe,Armenia,Cereal,Online,H,11/24/2014,683458888,12/28/2014,9528,205.70,117.11,1959909.60,1115824.08,844085.52
Sub-Saharan Africa,Eritrea,Cereal,Online,H,3/4/2015,679414975,4/17/2015,2844,205.70,117.11,585010.80,333060.84,251949.96
Europe,Montenegro,Clothes,Offline,M,5/17/2012,208630645,6/28/2012,7299,109.28,35.84,797634.72,261596.16,536038.56
Central America and the Caribbean,Jamaica,Vegetables,Online,H,1/29/2015,266467225,3/7/2015,2428,154.06,90.93,374057.68,220778.04,153279.64
Australia and Oceania,Fiji,Vegetables,Offline,H,12/24/2013,118598544,1/19/2014,4800,154.06,90.93,739488.00,436464.00,303024.00
Sub-Saharan Africa,Togo,Clothes,Online,M,12/29/2015,451010930,1/19/2016,3012,109.28,35.84,329151.36,107950.08,221201.28
Europe,Montenegro,Snacks,Offline,M,2/27/2010,220003211,3/18/2010,2694,152.58,97.44,411050.52,262503.36,148547.16
Europe,Greece,Household,Online,C,11/17/2016,702186715,12/22/2016,1508,668.27,502.54,1007751.16,757830.32,249920.84
Sub-Saharan Africa,Sudan,Cosmetics,Online,C,12/20/2015,544485270,1/5/2016,4146,437.20,263.33,1812631.20,1091766.18,720865.02
Asia,Maldives,Fruits,Offline,L,1/8/2011,714135205,2/6/2011,7332,9.33,6.92,68407.56,50737.44,17670.12
Europe,Montenegro,Clothes,Offline,H,6/28/2010,448685348,7/22/2010,4820,109.28,35.84,526729.60,172748.80,353980.80
Europe,Estonia,Office Supplies,Online,H,4/25/2016,405997025,5/12/2016,2397,651.21,524.96,1560950.37,1258329.12,302621.25
North America,Greenland,Beverages,Online,M,7/27/2012,414244067,8/7/2012,2880,47.45,31.79,136656.00,91555.20,45100.80
Sub-Saharan Africa,Cape Verde,Clothes,Online,C,9/8/2014,821912801,10/3/2014,1117,109.28,35.84,122065.76,40033.28,82032.48
Sub-Saharan Africa,Senegal,Household,Offline,L,8/27/2012,247802054,9/8/2012,8989,668.27,502.54,6007079.03,4517332.06,1489746.97
Australia and Oceania,Federated States of Micronesia,Snacks,Online,C,9/3/2012,531023156,10/15/2012,407,152.58,97.44,62100.06,39658.08,22441.98
Europe,Bulgaria,Clothes,Online,L,8/27/2010,880999934,9/16/2010,6313,109.28,35.84,689884.64,226257.92,463626.72
Middle East and North Africa,Algeria,Personal Care,Online,H,2/20/2011,127468717,3/9/2011,9681,81.73,56.67,791228.13,548622.27,242605.86
Asia,Mongolia,Clothes,Online,L,12/12/2015,770478332,1/24/2016,515,109.28,35.84,56279.20,18457.60,37821.60
Central America and the Caribbean,Grenada,Cereal,Online,H,10/28/2012,430390107,11/13/2012,852,205.70,117.11,175256.40,99777.72,75478.68
Central America and the Caribbean,Grenada,Beverages,Online,M,1/30/2017,397877871,3/20/2017,9759,47.45,31.79,463064.55,310238.61,152825.94
Sub-Saharan Africa,Senegal,Beverages,Offline,M,10/22/2014,683927953,11/4/2014,8334,47.45,31.79,395448.30,264937.86,130510.44
North America,Greenland,Fruits,Offline,M,1/31/2012,469839179,2/22/2012,4709,9.33,6.92,43934.97,32586.28,11348.69
Sub-Saharan Africa,Chad,Meat,Offline,H,1/20/2016,357222878,3/9/2016,9043,421.89,364.69,3815151.27,3297891.67,517259.60
Sub-Saharan Africa,Mauritius ,Personal Care,Online,C,1/1/2016,118002879,1/7/2016,8529,81.73,56.67,697075.17,483338.43,213736.74
Middle East and North Africa,Morocco,Beverages,Offline,C,6/1/2017,944415509,6/23/2017,2391,47.45,31.79,113452.95,76009.89,37443.06
Central America and the Caribbean,Honduras,Office Supplies,Online,H,6/30/2015,499009597,7/9/2015,6884,651.21,524.96,4482929.64,3613824.64,869105.00
Sub-Saharan Africa,Benin,Fruits,Online,L,1/28/2014,564646470,3/16/2014,293,9.33,6.92,2733.69,2027.56,706.13
Europe,Greece,Baby Food,Offline,M,4/8/2014,294499957,4/8/2014,7937,255.28,159.42,2026157.36,1265316.54,760840.82
Central America and the Caribbean,Jamaica,Beverages,Offline,L,9/4/2010,262056386,10/24/2010,7163,47.45,31.79,339884.35,227711.77,112172.58
Sub-Saharan Africa,Equatorial Guinea,Office Supplies,Online,M,5/2/2010,211114585,5/14/2010,2352,651.21,524.96,1531645.92,1234705.92,296940.00
Sub-Saharan Africa,Swaziland,Office Supplies,Offline,H,10/3/2013,405785882,10/22/2013,9915,651.21,524.96,6456747.15,5204978.40,1251768.75
Central America and the Caribbean,Trinidad and Tobago,Vegetables,Offline,M,3/6/2011,280494105,4/14/2011,3294,154.06,90.93,507473.64,299523.42,207950.22
Europe,Sweden,Baby Food,Online,L,8/7/2016,689975583,8/12/2016,7963,255.28,159.42,2032794.64,1269461.46,763333.18
Europe,Belarus,Office Supplies,Online,L,1/11/2011,759279143,2/18/2011,6426,651.21,524.96,4184675.46,3373392.96,811282.50
Sub-Saharan Africa,Guinea-Bissau,Office Supplies,Offline,C,5/21/2014,133766114,6/12/2014,3221,651.21,524.96,2097547.41,1690896.16,406651.25
Asia,Mongolia,Beverages,Online,M,8/3/2013,329110324,9/2/2013,9913,47.45,31.79,470371.85,315134.27,155237.58
Middle East and North Africa,Turkey,Meat,Online,L,10/5/2011,681298100,11/20/2011,103,421.89,364.69,43454.67,37563.07,5891.60
Sub-Saharan Africa,Central African Republic,Snacks,Offline,L,11/15/2016,596628272,12/30/2016,4419,152.58,97.44,674251.02,430587.36,243663.66
Sub-Saharan Africa,Equatorial Guinea,Office Supplies,Offline,L,4/3/2015,901712167,4/17/2015,5523,651.21,524.96,3596632.83,2899354.08,697278.75
Asia,Laos,Beverages,Online,M,3/22/2013,693473613,4/21/2013,3107,47.45,31.79,147427.15,98771.53,48655.62
Europe,Armenia,Meat,Online,C,8/2/2010,489148938,9/1/2010,8896,421.89,364.69,3753133.44,3244282.24,508851.20
Europe,Greece,Household,Online,L,1/5/2012,876286971,2/15/2012,1643,668.27,502.54,1097967.61,825673.22,272294.39
Middle East and North Africa,Israel,Personal Care,Offline,H,8/26/2015,262749040,8/30/2015,2135,81.73,56.67,174493.55,120990.45,53503.10
Asia,Bhutan,Meat,Online,H,12/9/2016,726708972,1/26/2017,8189,421.89,364.69,3454857.21,2986446.41,468410.80
Australia and Oceania,Vanuatu,Vegetables,Online,L,5/17/2012,366653096,5/31/2012,9654,154.06,90.93,1487295.24,877838.22,609457.02
Sub-Saharan Africa,Burundi,Vegetables,Online,M,11/17/2010,951380240,12/20/2010,3410,154.06,90.93,525344.60,310071.30,215273.30
Europe,Ukraine,Cosmetics,Online,M,11/13/2014,270001733,1/1/2015,8368,437.20,263.33,3658489.60,2203545.44,1454944.16
Europe,Croatia,Beverages,Online,C,6/16/2016,681941401,7/28/2016,470,47.45,31.79,22301.50,14941.30,7360.20
Sub-Saharan Africa,Madagascar,Fruits,Online,L,5/31/2016,566935575,6/7/2016,7690,9.33,6.92,71747.70,53214.80,18532.90
Asia,Malaysia,Snacks,Offline,M,10/6/2012,175033080,11/5/2012,5033,152.58,97.44,767935.14,490415.52,277519.62
Asia,Uzbekistan,Office Supplies,Offline,L,3/10/2012,276595246,3/15/2012,9535,651.21,524.96,6209287.35,5005493.60,1203793.75
Europe,Italy,Office Supplies,Online,M,1/26/2011,812295901,2/13/2011,5263,651.21,524.96,3427318.23,2762864.48,664453.75
Asia,Nepal,Vegetables,Offline,C,6/2/2014,443121373,6/19/2014,8316,154.06,90.93,1281162.96,756173.88,524989.08
Australia and Oceania,Fiji,Personal Care,Offline,H,12/17/2016,600370490,1/25/2017,1824,81.73,56.67,149075.52,103366.08,45709.44
Europe,Portugal,Office Supplies,Online,L,6/27/2014,535654580,7/29/2014,949,651.21,524.96,617998.29,498187.04,119811.25
Central America and the Caribbean,Panama,Cosmetics,Offline,H,3/17/2015,470897471,4/22/2015,7881,437.20,263.33,3445573.20,2075303.73,1370269.47
Europe,Belarus,Beverages,Offline,L,4/3/2013,248335492,4/4/2013,6846,47.45,31.79,324842.70,217634.34,107208.36
Sub-Saharan Africa,Botswana,Clothes,Offline,C,3/8/2015,680517470,3/25/2015,9097,109.28,35.84,994120.16,326036.48,668083.68
Sub-Saharan Africa,Tanzania,Personal Care,Online,M,6/21/2013,400304734,7/29/2013,7921,81.73,56.67,647383.33,448883.07,198500.26
Europe,Romania,Office Supplies,Offline,C,1/6/2013,810871112,1/8/2013,3636,651.21,524.96,2367799.56,1908754.56,459045.00
Sub-Saharan Africa,Mali,Cereal,Online,L,3/17/2012,235702931,4/3/2012,8590,205.70,117.11,1766963.00,1005974.90,760988.10
Sub-Saharan Africa,Central African Republic,Office Supplies,Offline,C,4/18/2014,668599021,5/12/2014,2163,651.21,524.96,1408567.23,1135488.48,273078.75
Sub-Saharan Africa,Niger,Baby Food,Online,M,1/3/2016,123670709,2/1/2016,5766,255.28,159.42,1471944.48,919215.72,552728.76
Europe,Austria,Office Supplies,Online,L,5/12/2011,285341823,6/8/2011,7841,651.21,524.96,5106137.61,4116211.36,989926.25
Asia,India,Fruits,Online,H,7/29/2010,658348691,8/22/2010,8862,9.33,6.92,82682.46,61325.04,21357.42
Europe,Luxembourg,Baby Food,Offline,L,8/2/2013,817740142,8/19/2013,6335,255.28,159.42,1617198.80,1009925.70,607273.10
Sub-Saharan Africa,Cape Verde,Beverages,Offline,H,10/23/2013,858877503,11/6/2013,9794,47.45,31.79,464725.30,311351.26,153374.04
Europe,Sweden,Vegetables,Offline,M,2/5/2017,947434604,2/19/2017,5808,154.06,90.93,894780.48,528121.44,366659.04
Europe,Iceland,Meat,Offline,H,3/20/2015,869397771,4/17/2015,2975,421.89,364.69,1255122.75,1084952.75,170170.00
Middle East and North Africa,Qatar,Personal Care,Offline,L,5/6/2012,481065833,5/8/2012,6925,81.73,56.67,565980.25,392439.75,173540.50
Sub-Saharan Africa,South Sudan,Meat,Online,C,9/30/2013,159050118,10/1/2013,5319,421.89,364.69,2244032.91,1939786.11,304246.80
Europe,United Kingdom,Office Supplies,Online,M,5/20/2014,350274455,6/14/2014,2850,651.21,524.96,1855948.50,1496136.00,359812.50
Middle East and North Africa,Tunisia ,Cereal,Online,L,4/9/2010,221975171,5/17/2010,6241,205.70,117.11,1283773.70,730883.51,552890.19
North America,United States of America,Office Supplies,Online,C,6/9/2017,811701095,7/19/2017,9247,651.21,524.96,6021738.87,4854305.12,1167433.75
Sub-Saharan Africa,Liberia,Cereal,Online,L,2/8/2015,977313554,3/29/2015,7653,205.70,117.11,1574222.10,896242.83,677979.27
Sub-Saharan Africa,Eritrea,Snacks,Offline,L,1/25/2010,546986377,2/10/2010,4279,152.58,97.44,652889.82,416945.76,235944.06
Asia,South Korea,Fruits,Offline,L,3/7/2010,769205892,3/17/2010,3972,9.33,6.92,37058.76,27486.24,9572.52
Sub-Saharan Africa,Kenya,Clothes,Offline,M,1/3/2013,262770926,2/8/2013,8611,109.28,35.84,941010.08,308618.24,632391.84
Sub-Saharan Africa,Rwanda,Snacks,Online,M,3/6/2017,866792809,3/18/2017,2109,152.58,97.44,321791.22,205500.96,116290.26
Central America and the Caribbean,Cuba,Beverages,Offline,C,1/9/2011,890695369,2/23/2011,5408,47.45,31.79,256609.60,171920.32,84689.28
Middle East and North Africa,Libya,Cereal,Offline,M,3/27/2014,964214932,3/31/2014,1480,205.70,117.11,304436.00,173322.80,131113.20
Europe,Czech Republic,Snacks,Online,C,6/28/2013,887400329,8/17/2013,332,152.58,97.44,50656.56,32350.08,18306.48
Europe,Montenegro,Beverages,Offline,M,9/4/2011,980612885,9/4/2011,3999,47.45,31.79,189752.55,127128.21,62624.34
Europe,Montenegro,Clothes,Offline,M,7/14/2016,734526431,8/2/2016,1549,109.28,35.84,169274.72,55516.16,113758.56
Asia,Philippines,Baby Food,Online,L,2/23/2014,160127294,3/23/2014,4079,255.28,159.42,1041287.12,650274.18,391012.94
Central America and the Caribbean,El Salvador,Clothes,Offline,L,8/7/2010,238714301,9/13/2010,9721,109.28,35.84,1062310.88,348400.64,713910.24
Australia and Oceania,Tonga,Household,Online,M,1/14/2013,671898782,2/6/2013,8635,668.27,502.54,5770511.45,4339432.90,1431078.55
Sub-Saharan Africa,Democratic Republic of the Congo,Personal Care,Offline,H,9/30/2010,331604564,11/17/2010,8014,81.73,56.67,654984.22,454153.38,200830.84
Middle East and North Africa,Afghanistan,Cereal,Online,M,10/13/2016,410067975,11/20/2016,7081,205.70,117.11,1456561.70,829255.91,627305.79
Australia and Oceania,Tuvalu,Snacks,Offline,L,3/16/2011,369837844,3/23/2011,2091,152.58,97.44,319044.78,203747.04,115297.74
Sub-Saharan Africa,Sudan,Fruits,Online,L,12/26/2012,193775498,1/31/2013,1331,9.33,6.92,12418.23,9210.52,3207.71
Sub-Saharan Africa,Niger,Clothes,Online,M,9/2/2015,835054767,10/9/2015,117,109.28,35.84,12785.76,4193.28,8592.48
Sub-Saharan Africa,Gabon,Household,Offline,C,11/11/2013,167161977,12/24/2013,5798,668.27,502.54,3874629.46,2913726.92,960902.54
Australia and Oceania,East Timor,Vegetables,Offline,C,8/4/2014,633895957,8/22/2014,2755,154.06,90.93,424435.30,250512.15,173923.15
```
@eval_with_csv

``` sql
/*
select some stuff
*/
SELECT Region FROM one;
```
@eval


``` sql
SELECT * FROM one Where Region == "North America";
```
@eval


Find out what you can even do more with quizzes:

https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/docs/master/README.md
