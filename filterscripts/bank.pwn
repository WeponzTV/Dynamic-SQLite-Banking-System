/* Dynamic SQLite Banking System (SA-MP) by Weponz */
#define FILTERSCRIPT
#include <a_samp>//Credits: SA-MP Team
#include <streamer>//Credits: Incognito
#include <zcmd>//Credits: ZeeX

#define ERROR 0xFF0000FF//Red
#define SERVER 0xFFFFFFFF//White

#define MAX_BANKS 10//Increase the number to allow for more bank to be created.

#define BANK_DATABASE "bank.db"//Change this to the location of your database. (Optional)

#define BANK_EXIT_X 2304.6865//Change this to the coordinates of your bank exit point.
#define BANK_EXIT_Y -16.1609//Change this to the coordinates of your bank exit point.
#define BANK_EXIT_Z 26.7422//Change this to the coordinates of your bank exit point.

#define BANK_MENU_X 2316.6213//Change this to the coordinates of your bank menu point.
#define BANK_MENU_Y -7.3550//Change this to the coordinates of your bank menu point.
#define BANK_MENU_Z 26.7422//Change this to the coordinates of your bank menu point.

#define BANK_TELLER_X 2318.3074//Change this to the coordinates of your bank actor point.
#define BANK_TELLER_Y -7.3343//Change this to the coordinates of your bank actor point.
#define BANK_TELLER_Z 26.7496//Change this to the coordinates of your bank actor point.
#define BANK_TELLER_A 87.9017//Change this to the coordinates of your bank actor point.

#define BANK_TELLER_SKIN 141//Change the skin of the bank teller here. (Optional)

#define BANK_SPAWN_X 2306.8186//Change this to the coordinates of your bank spawn point.
#define BANK_SPAWN_Y -16.1437//Change this to the coordinates of your bank spawn point.
#define BANK_SPAWN_Z 26.7496//Change this to the coordinates of your bank spawn point.
#define BANK_SPAWN_A 269.4367//Change this to the coordinates of your bank spawn point.

#define BANK_SPAWN_INT 0//Change this to the interior id of your bank (IF ABOVE CHANGED)

#define BANK_ZONE 150.0//Decrease to allow banks to be created closer to each other.

#define BANK_EDIT_DIALOG 1011//Change the dialog ids if it clashes with other scripts.
#define BANK_NAME_DIALOG 1012//Change the dialog ids if it clashes with other scripts.
#define BANK_MENU_DIALOG 1013//Change the dialog ids if it clashes with other scripts.
#define BANK_BALANCE_DIALOG 1014//Change the dialog ids if it clashes with other scripts.
#define BANK_WITHDRAW_DIALOG 1015//Change the dialog ids if it clashes with other scripts.
#define BANK_DEPOSIT_DIALOG 1016//Change the dialog ids if it clashes with other scripts.
#define BANK_DEBT_DIALOG 1017//Change the dialog ids if it clashes with other scripts.
#define BANK_LOANS_DIALOG 1018//Change the dialog ids if it clashes with other scripts.
#define BANK_PAY_DIALOG 1019//Change the dialog ids if it clashes with other scripts.

new DB:bank_database;
new DBResult:database_result;

enum server_data
{
 	server_actor,
 	server_menu
};
new ServerData[server_data];

enum bank_data
{
	bank_name[64],
 	Float:bank_extx,
 	Float:bank_exty,
 	Float:bank_extz,
 	Float:bank_spawnx,
 	Float:bank_spawny,
 	Float:bank_spawnz,
 	Float:bank_spawna,
 	Float:bank_intx,
 	Float:bank_inty,
 	Float:bank_intz,
 	Float:bank_inta,
 	bank_world,
 	bank_icon,
 	bank_entry,
 	bank_exit,
 	bank_loans,
 	Text3D:bank_label,
 	bool:bank_active
};
new BankData[MAX_BANKS][bank_data];

enum account_data
{
 	account_balance,
 	account_debt,
 	account_editing
};
new AccountData[MAX_PLAYERS][account_data];

enum zone_data
{
	zone_name[28],
	Float:zone_area[6]
};

static const sa_zones[][zone_data] =
{
	{"The Big Ear",	                {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
	{"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
	{"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
	{"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
	{"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
	{"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
	{"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
	{"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
	{"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
	{"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
	{"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
	{"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
	{"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
	{"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
	{"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
	{"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
	{"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
	{"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
	{"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
	{"Blackfield Intersection",     {1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
	{"Blackfield Intersection",     {1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
	{"Blackfield Intersection",     {1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
	{"Blackfield Intersection",     {1375.60,823.20,-89.00,1457.30,919.40,110.90}},
	{"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
	{"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
	{"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
	{"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
	{"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
	{"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
	{"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
	{"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
	{"Come-A-Lot",                  {2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
	{"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
	{"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
	{"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
	{"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
	{"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
	{"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
	{"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
	{"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
	{"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
	{"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
	{"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
	{"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
	{"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
	{"Downtown",                    {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
	{"Downtown",                    {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
	{"Downtown",                    {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
	{"Downtown",                    {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
	{"Downtown",                    {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
	{"Downtown",                    {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
	{"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
	{"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
	{"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
	{"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
	{"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
	{"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
	{"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
	{"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
	{"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
	{"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
	{"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
	{"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
	{"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
	{"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
	{"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
	{"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
	{"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
	{"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
	{"Easter Bay Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
	{"Easter Bay Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
	{"Easter Bay Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
	{"Easter Bay Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
	{"Easter Bay Chemicals",        {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
	{"Easter Bay Chemicals",        {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
	{"El Castillo del Diablo",      {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
	{"El Castillo del Diablo",      {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
	{"El Castillo del Diablo",      {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
	{"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
	{"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
	{"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
	{"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
	{"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
	{"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
	{"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
	{"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
	{"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
	{"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
	{"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
	{"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
	{"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
	{"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
	{"Flint Intersection",          {-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
	{"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
	{"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
	{"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
	{"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
	{"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
	{"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
	{"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
	{"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
	{"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
	{"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
	{"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
	{"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
	{"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
	{"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
	{"Glen Park",                   {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
	{"Glen Park",                   {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
	{"Glen Park",                   {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
	{"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
	{"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
	{"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
	{"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
	{"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
	{"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
	{"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
	{"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
	{"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
	{"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
	{"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
	{"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
	{"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
	{"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
	{"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
	{"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
	{"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
	{"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
	{"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
	{"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
	{"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
	{"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
	{"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
	{"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
	{"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
	{"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
	{"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
	{"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
	{"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
	{"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
	{"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
	{"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
	{"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
	{"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
	{"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
	{"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
	{"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
	{"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
	{"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
	{"K.A.C.C. Military Fuels",     {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
	{"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
	{"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
	{"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
	{"King's",                      {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
	{"King's",                      {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
	{"King's",                      {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
	{"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
	{"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
	{"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
	{"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
	{"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
	{"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
	{"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
	{"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
	{"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
	{"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
	{"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
	{"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
	{"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
	{"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
	{"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
	{"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
	{"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
	{"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
	{"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
	{"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
	{"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
	{"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
	{"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
	{"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
	{"Little Mexico",               {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
	{"Little Mexico",               {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
	{"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
	{"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
	{"Los Santos International",    {1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
	{"Los Santos International",    {1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
	{"Los Santos International",    {1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
	{"Los Santos International",    {1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
	{"Los Santos International",    {1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
	{"Los Santos International",    {2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
	{"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
	{"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
	{"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
	{"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
	{"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
	{"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
	{"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
	{"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
	{"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
	{"Missionary Hill",             {-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
	{"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
	{"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
	{"Montgomery Intersection",     {1546.60,208.10,0.00,1745.80,347.40,200.00}},
	{"Montgomery Intersection",     {1582.40,347.40,0.00,1664.60,401.70,200.00}},
	{"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
	{"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
	{"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
	{"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
	{"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
	{"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
	{"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
	{"Mulholland",                  {687.80,-860.60,-89.00,911.80,-768.00,110.90}},
	{"Mulholland",                  {737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
	{"Mulholland",                  {1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
	{"Mulholland",                  {952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
	{"Mulholland",                  {911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
	{"Mulholland",                  {861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
	{"Mulholland Intersection",     {1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
	{"North Rock",                  {2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
	{"Ocean Docks",                 {2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
	{"Ocean Docks",                 {2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
	{"Ocean Docks",                 {2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
	{"Ocean Docks",                 {2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
	{"Ocean Docks",                 {2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
	{"Ocean Docks",                 {2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
	{"Ocean Docks",                 {2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
	{"Ocean Flats",                 {-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
	{"Octane Springs",              {338.60,1228.50,0.00,664.30,1655.00,200.00}},
	{"Old Venturas Strip",          {2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
	{"Palisades",                   {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
	{"Palomino Creek",              {2160.20,-149.00,0.00,2576.90,228.30,200.00}},
	{"Paradiso",                    {-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
	{"Pershing Square",             {1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
	{"Pilgrim",                     {2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
	{"Pilgrim",                     {2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
	{"Pilson Intersection",         {1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
	{"Pirates in Men's Pants",      {1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
	{"Playa del Seville",           {2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
	{"Prickle Pine",                {1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
	{"Prickle Pine",                {1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
	{"Prickle Pine",                {1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
	{"Prickle Pine",                {1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
	{"Queens",                      {-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
	{"Queens",                      {-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
	{"Queens",                      {-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
	{"Randolph Industrial Estate",  {1558.00,596.30,-89.00,1823.00,823.20,110.90}},
	{"Redsands East",               {1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
	{"Redsands East",               {1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
	{"Redsands East",               {1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
	{"Redsands West",               {1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
	{"Redsands West",               {1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
	{"Redsands West",               {1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
	{"Redsands West",               {1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
	{"Regular Tom",                 {-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
	{"Richman",                     {647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
	{"Richman",                     {647.50,-954.60,-89.00,768.60,-860.60,110.90}},
	{"Richman",                     {225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
	{"Richman",                     {225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
	{"Richman",                     {72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
	{"Richman",                     {72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
	{"Richman",                     {321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
	{"Richman",                     {321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
	{"Richman",                     {321.30,-860.60,-89.00,687.80,-768.00,110.90}},
	{"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
	{"Robada Intersection",         {-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
	{"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
	{"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
	{"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
	{"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
	{"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
	{"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
	{"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
	{"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
	{"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
	{"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
	{"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
	{"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
	{"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
	{"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
	{"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
	{"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
	{"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
	{"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
	{"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
	{"Santa Flora",                 {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
	{"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
	{"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
	{"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
	{"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
	{"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
	{"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
	{"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
	{"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
	{"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
	{"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
	{"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
	{"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
	{"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
	{"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
	{"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
	{"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
	{"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
	{"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
	{"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
	{"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
	{"The Four Dragons Casino",     {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
	{"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
	{"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
	{"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
	{"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
	{"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
	{"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
	{"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
	{"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
	{"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
	{"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
	{"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
	{"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
	{"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
	{"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
	{"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
	{"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
	{"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
	{"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
	{"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
	{"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
	{"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
	{"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
	{"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
	{"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
	{"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
	{"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
	{"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
	{"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
	{"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
	{"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
	{"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
	{"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
	{"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
	{"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
	{"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
	{"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
	{"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
	{"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
	{"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
	{"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
	{"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
	{"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
	{"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
	{"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
	{"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};

stock IsNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
    return 1;
}

stock DB_Escape(text[])
{
    new ret[80 * 2], ch, i, j;
    while ((ch = text[i++]) && j < sizeof (ret))
    {
        if (ch == '\'')
        {
            if (j < sizeof (ret) - 2)
            {
                ret[j++] = '\'';
                ret[j++] = '\'';
            }
        }
        else if (j < sizeof (ret))
        {
            ret[j++] = ch;
        }
        else
        {
            j++;
        }
    }
    ret[sizeof (ret) - 1] = '\0';
    return ret;
}

stock GetXYBehindPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if(GetPlayerVehicleID(playerid))
	{
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x -= (distance * floatsin(-a, degrees));
	y -= (distance * floatcos(-a, degrees));
}

stock GetName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

stock GetFreeBankSlot()
{
	new slot = -1;
	for(new i = 0; i < MAX_BANKS; i++)
	{
	    new query[256];
	    format(query, sizeof(query), "SELECT `ID` FROM `BANKS` WHERE `ID` = '%d'", i);
    	database_result = db_query(bank_database, query);
    	if(!db_num_rows(database_result))
    	{
    	    return i;
    	}
    	db_free_result(database_result);
	}
	return slot;
}

stock IsPlayerInRangeOfBank(playerid, Float:distance)
{
	for(new i = 0; i < MAX_BANKS; i++)
	{
	    if(BankData[i][bank_active] == true)
	    {
	        if(IsPlayerInRangeOfPoint(playerid, distance, BankData[i][bank_extx], BankData[i][bank_exty], BankData[i][bank_extz])) return i;
	    }
	}
	return -1;
}

stock LoadBanks()
{
	new query[800], field[64];
    for(new i = 0; i < MAX_BANKS; i++)
	{
	    format(query, sizeof(query), "SELECT * FROM `BANKS` WHERE `ID` = '%d'", i);
    	database_result = db_query(bank_database, query);
    	if(db_num_rows(database_result))
    	{
          	db_get_field_assoc(database_result, "NAME", field, sizeof(field));
          	BankData[i][bank_name] = field;

          	db_get_field_assoc(database_result, "EXTX", field, sizeof(field));
          	BankData[i][bank_extx] = floatstr(field);

          	db_get_field_assoc(database_result, "EXTY", field, sizeof(field));
          	BankData[i][bank_exty] = floatstr(field);

          	db_get_field_assoc(database_result, "EXTZ", field, sizeof(field));
          	BankData[i][bank_extz] = floatstr(field);

          	db_get_field_assoc(database_result, "SPAWNX", field, sizeof(field));
          	BankData[i][bank_spawnx] = floatstr(field);

          	db_get_field_assoc(database_result, "SPAWNY", field, sizeof(field));
          	BankData[i][bank_spawny] = floatstr(field);

          	db_get_field_assoc(database_result, "SPAWNZ", field, sizeof(field));
          	BankData[i][bank_spawnz] = floatstr(field);

          	db_get_field_assoc(database_result, "SPAWNA", field, sizeof(field));
          	BankData[i][bank_spawna] = floatstr(field);

          	db_get_field_assoc(database_result, "LOANS", field, sizeof(field));
          	BankData[i][bank_loans] = strval(field);
          	
    		db_free_result(database_result);

			BankData[i][bank_intx] = BANK_SPAWN_X;
			BankData[i][bank_inty] = BANK_SPAWN_Y;
			BankData[i][bank_intz] = BANK_SPAWN_Z;
			BankData[i][bank_inta] = BANK_SPAWN_A;

			BankData[i][bank_label] = CreateDynamic3DTextLabel(BankData[i][bank_name], SERVER, BankData[i][bank_extx], BankData[i][bank_exty], BankData[i][bank_extz], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 10.0);
			BankData[i][bank_icon] = CreateDynamicMapIcon(BankData[i][bank_extx], BankData[i][bank_exty], BankData[i][bank_extz], 52, -1, -1, -1, -1, 250.0);

            BankData[i][bank_entry] = CreateDynamicCP(BankData[i][bank_extx], BankData[i][bank_exty], BankData[i][bank_extz], 1.0, -1, -1, -1, 5.0, -1, 1);
            BankData[i][bank_exit] = CreateDynamicCP(BANK_EXIT_X, BANK_EXIT_Y, BANK_EXIT_Z, 1.0, i, -1, -1, 5.0, -1, 1);

			BankData[i][bank_active] = true;
		}
	}

	ServerData[server_actor] = CreateDynamicActorEx(BANK_TELLER_SKIN, BANK_TELLER_X, BANK_TELLER_Y, BANK_TELLER_Z, BANK_TELLER_A, 1, 100.0, 50.0);
	SetDynamicActorPos(ServerData[server_actor], BANK_TELLER_X, BANK_TELLER_Y, BANK_TELLER_Z);
	SetDynamicActorInvulnerable(ServerData[server_actor], true);

	ServerData[server_menu] = CreateDynamicCP(BANK_MENU_X, BANK_MENU_Y, BANK_MENU_Z, 1.0, -1, -1, -1, 5.0, -1, 1);
	return 1;
}

stock UnloadBanks()
{
    for(new i = 0; i < MAX_BANKS; i++)
	{
	    if(BankData[i][bank_active] == true)
	    {
			BankData[i][bank_active] = false;

			DestroyDynamicMapIcon(BankData[i][bank_icon]);
			
			DestroyDynamicCP(BankData[i][bank_entry]);
			DestroyDynamicCP(BankData[i][bank_exit]);
			
			DestroyDynamic3DTextLabel(BankData[i][bank_label]);
	    }
	}
	
	DestroyDynamicActor(ServerData[server_actor]);
	DestroyDynamicCP(ServerData[server_menu]);
	return 1;
}

stock LoadPlayerAccount(playerid)
{
	new query[64 + MAX_PLAYER_NAME]; // does not need to be 256 characters long...

    format(query, sizeof(query), "SELECT * FROM `ACCOUNTS` WHERE `NAME` = '%q'", GetName(playerid)); // we dont need DB_Escape when we have %q as a format specifier.
    new DBResult:res = db_query(db, query);

    if(db_num_rows(res))
    {
        AccountData[playerid][account_balance] =  db_get_field_assoc_int(res, "BALANCE");
        AccountData[playerid][account_debt] = db_get_field_assoc_int(res, "DEBT");
        AccountData[playerid][account_editing] = -1;
    }
    else
    {
        format(query, sizeof(query), "INSERT INTO `ACCOUNTS` (`NAME`, `BALANCE`, `DEBT`) VALUES ('%q', '0', '0')", GetName(playerid));
        db_free_result(db_query(db, query));
    }

    db_free_result(res); // Regardless of the outcome of either control statement, we must free the result.
	return 1;
}

stock SavePlayerAccount(playerid)
{
	new query[128];
	format(query, sizeof(query), "UPDATE `ACCOUNTS` SET `BALANCE` = '%d', `DEBT` = '%d' WHERE `NAME` = '%s' COLLATE NOCASE", AccountData[playerid][account_balance], AccountData[playerid][account_debt], DB_Escape(GetName(playerid)));
	database_result = db_query(bank_database, query);
	db_free_result(database_result);
	return 1;
}

stock ShowBankMenu(playerid)
{
    new bankid = GetPlayerVirtualWorld(playerid);
	if(BankData[bankid][bank_loans] == 1)
	{
		return ShowPlayerDialog(playerid, BANK_MENU_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Menu", "{FFFFFF}Balance\nWithdraw\nDeposit\nDebt\nLoans", "Select", "Cancel");
	}
	else
	{
 		ShowPlayerDialog(playerid, BANK_MENU_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Menu", "{FFFFFF}Balance\nWithdraw\nDeposit", "Select", "Cancel");
	}
	return 1;
}

public OnFilterScriptInit()
{
    bank_database = db_open(BANK_DATABASE);
    db_query(bank_database, "CREATE TABLE IF NOT EXISTS `BANKS` (`ID`, `NAME`, `EXTX`, `EXTY`, `EXTZ`, `SPAWNX`, `SPAWNY`, `SPAWNZ`, `SPAWNA`, `LOANS`)");
    db_query(bank_database, "CREATE TABLE IF NOT EXISTS `ACCOUNTS` (`NAME`, `BALANCE`, `DEBT`)");
	
	LoadBanks();
	return 1;
}

public OnFilterScriptExit()
{
    UnloadBanks();
    
    db_close(bank_database);
	return 1;
}

public OnPlayerConnect(playerid)
{
	AccountData[playerid][account_balance] = 0;
	AccountData[playerid][account_debt] = 0;
	AccountData[playerid][account_editing] = -1;
	
    LoadPlayerAccount(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    SavePlayerAccount(playerid);
    
	AccountData[playerid][account_balance] = 0;
	AccountData[playerid][account_debt] = 0;
	AccountData[playerid][account_editing] = -1;
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	new query[256], string[128], name[64];
	if(dialogid == BANK_EDIT_DIALOG)
	{
	    if(response)
	    {
			new bankid = AccountData[playerid][account_editing];
		    if(listitem == 0)
		    {
		        return ShowPlayerDialog(playerid, BANK_NAME_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Bank Settings > Change Name", "{FFFFFF}Please enter a new name for the bank below:", "Enter", "Cancel");
		    }
		    else if(listitem == 1)
		    {
		        if(BankData[bankid][bank_loans] == 1)
				{
				    BankData[bankid][bank_loans] = 0;
				    
		        	format(query, sizeof(query), "UPDATE `BANKS` SET `LOANS` = '%d' WHERE `ID` = '%d' COLLATE NOCASE", BankData[bankid][bank_loans], bankid);
					database_result = db_query(bank_database, query);
					db_free_result(database_result);
				
					format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Disabled", BankData[bankid][bank_name]);
				}
				else
				{
				    BankData[bankid][bank_loans] = 1;

		        	format(query, sizeof(query), "UPDATE `BANKS` SET `LOANS` = '%d' WHERE `ID` = '%d' COLLATE NOCASE", BankData[bankid][bank_loans], bankid);
					database_result = db_query(bank_database, query);
					db_free_result(database_result);
					
					format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Enabled", BankData[bankid][bank_name]);
				}
			  	ShowPlayerDialog(playerid, BANK_EDIT_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Settings", string, "Edit", "Cancel");
		    }
	    }
	    return 1;
	}
	else if(dialogid == BANK_NAME_DIALOG)
	{
	    if(response)
	    {
			new bankid = AccountData[playerid][account_editing];
	        if(strlen(inputtext) < 3 || strlen(inputtext) > 64) return SendClientMessage(playerid, ERROR, "ERROR: The bank name must be from 3-64 characters long.");

			format(name, sizeof(name), "%s", inputtext);
	        BankData[bankid][bank_name] = name;

			UpdateDynamic3DTextLabelText(BankData[bankid][bank_label], SERVER, BankData[bankid][bank_name]);
	        
	        format(query, sizeof(query), "UPDATE `BANKS` SET `NAME` = '%s' WHERE `ID` = '%d' COLLATE NOCASE", DB_Escape(BankData[bankid][bank_name]), bankid);
			database_result = db_query(bank_database, query);
			db_free_result(database_result);
	        
	        if(BankData[bankid][bank_loans] == 1)
			{
				format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Enabled", BankData[bankid][bank_name]);
			}
			else
			{
				format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Disabled", BankData[bankid][bank_name]);
			}
			ShowPlayerDialog(playerid, BANK_EDIT_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Settings", string, "Edit", "Cancel");
	    }
	    return 1;
	}
	else if(dialogid == BANK_BALANCE_DIALOG)
	{
	    if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
		return 1;
	}
	else if(dialogid == BANK_WITHDRAW_DIALOG)
	{
	    if(response)
	    {
	        new balance = AccountData[playerid][account_balance];
	        if(!IsNumeric(inputtext) || strlen(inputtext) < 1) return SendClientMessage(playerid, ERROR, "ERROR: You must input a number value greater than 0.");
	        if(strval(inputtext) > balance) return SendClientMessage(playerid, ERROR, "ERROR: Insufficient funds.");
	        
	        new amount = strval(inputtext);
	        AccountData[playerid][account_balance] = AccountData[playerid][account_balance] - amount;

			GivePlayerMoney(playerid, amount);
			
			SavePlayerAccount(playerid);

			format(string, sizeof(string), "SERVER: You have successfully withdraw $%d from your bank account.", amount);
			return SendClientMessage(playerid, SERVER, string);
	    }
	    else if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
		return 1;
	}
	else if(dialogid == BANK_DEPOSIT_DIALOG)
	{
	    if(response)
	    {
	        if(!IsNumeric(inputtext) || strlen(inputtext) < 1) return SendClientMessage(playerid, ERROR, "ERROR: You must input a number value greater than 0.");
	        if(strval(inputtext) > GetPlayerMoney(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: Insufficient funds.");

	        new amount = strval(inputtext);
	        AccountData[playerid][account_balance] = AccountData[playerid][account_balance] + amount;

			GivePlayerMoney(playerid, - amount);

			SavePlayerAccount(playerid);

			format(string, sizeof(string), "SERVER: You have successfully deposited $%d into your bank account.", amount);
			return SendClientMessage(playerid, SERVER, string);
	    }
	    else if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
		return 1;
	}
	else if(dialogid == BANK_DEBT_DIALOG)
	{
	    if(response)
	    {
			return ShowPlayerDialog(playerid, BANK_PAY_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Bank Menu > Debt", "{FFFFFF}Please enter the amount you want to pay back below:", "Enter", "Back");
		}
	    else if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
		return 1;
	}
	else if(dialogid == BANK_PAY_DIALOG)
	{
	    if(response)
	    {
	        new amount = strval(inputtext), debt = AccountData[playerid][account_debt];
	        if(!IsNumeric(inputtext) || strlen(inputtext) < 1) return SendClientMessage(playerid, ERROR, "ERROR: You must input a number value greater than 0.");
	        if(strval(inputtext) > GetPlayerMoney(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: Insufficient funds.");
	        if(amount > debt) return SendClientMessage(playerid, ERROR, "ERROR: You do not owe that much money to the bank.");
	        
	        AccountData[playerid][account_debt] = AccountData[playerid][account_debt] - amount;
	        
			GivePlayerMoney(playerid, - amount);

			SavePlayerAccount(playerid);

			format(string, sizeof(string), "SERVER: You have successfully payed off $%d of your debt.", amount);
			return SendClientMessage(playerid, SERVER, string);
	    }
	    else if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
	    return 1;
	}
	else if(dialogid == BANK_LOANS_DIALOG)
	{
	    if(response)
	    {
		    if(listitem == 0)
		    {
				new amount = 500000, interest = amount / 8, funds = GetPlayerMoney(playerid), rating = (amount / 2);
				if(AccountData[playerid][account_debt] > 0) return SendClientMessage(playerid, ERROR, "ERROR: You cannot apply for anymore loans until your debt is payed off.");
				if(funds < rating)
				{
					format(string, sizeof(string), "ERROR: You need at least $%d to apply for this loan.", rating);
					return SendClientMessage(playerid, ERROR, string);
				}
				
				AccountData[playerid][account_debt] = (amount + interest);

				GivePlayerMoney(playerid, amount);

				SavePlayerAccount(playerid);

				return SendClientMessage(playerid, SERVER, "SERVER: You have successfully applied for the loan and was approved for $500000.");
		    }
		    else if(listitem == 1)
		    {
				new amount = 1000000, interest = amount / 8, funds = GetPlayerMoney(playerid), rating = (amount / 2);
				if(AccountData[playerid][account_debt] > 0) return SendClientMessage(playerid, ERROR, "ERROR: You cannot apply for anymore loans until your debt is payed off.");
				if(funds < rating)
				{
					format(string, sizeof(string), "ERROR: You need at least $%d to apply for this loan.", rating);
					return SendClientMessage(playerid, ERROR, string);
				}

				AccountData[playerid][account_debt] = (amount + interest);

				GivePlayerMoney(playerid, amount);

				SavePlayerAccount(playerid);

				return SendClientMessage(playerid, SERVER, "SERVER: You have successfully applied for the loan and was approved for $1000000.");
		    }
		    else if(listitem == 2)
		    {
				new amount = 5000000, interest = amount / 8, funds = GetPlayerMoney(playerid), rating = (amount / 2);
				if(AccountData[playerid][account_debt] > 0) return SendClientMessage(playerid, ERROR, "ERROR: You cannot apply for anymore loans until your debt is payed off.");
				if(funds < rating)
				{
					format(string, sizeof(string), "ERROR: You need at least $%d to apply for this loan.", rating);
					return SendClientMessage(playerid, ERROR, string);
				}

				AccountData[playerid][account_debt] = (amount + interest);

				GivePlayerMoney(playerid, amount);

				SavePlayerAccount(playerid);

				return SendClientMessage(playerid, SERVER, "SERVER: You have successfully applied for the loan and was approved for $5000000.");
		    }
		    else if(listitem == 3)
		    {
				new amount = 10000000, interest = amount / 8, funds = GetPlayerMoney(playerid), rating = (amount / 2);
				if(AccountData[playerid][account_debt] > 0) return SendClientMessage(playerid, ERROR, "ERROR: You cannot apply for anymore loans until your debt is payed off.");
				if(funds < rating)
				{
					format(string, sizeof(string), "ERROR: You need at least $%d to apply for this loan.", rating);
					return SendClientMessage(playerid, ERROR, string);
				}

				AccountData[playerid][account_debt] = (amount + interest);

				GivePlayerMoney(playerid, amount);

				SavePlayerAccount(playerid);

				SendClientMessage(playerid, SERVER, "SERVER: You have successfully applied for the loan and was approved for $10000000.");
		    }
		    return 1;
	    }
	    else if(!response)
	    {
	        ShowBankMenu(playerid);
	    }
	    return 1;
	}
	else if(dialogid == BANK_MENU_DIALOG)
	{
	    if(response)
	    {
		    if(listitem == 0)
		    {
		        format(string, sizeof(string), "{FFFFFF}Balance: $%d", AccountData[playerid][account_balance]);
		        return ShowPlayerDialog(playerid, BANK_BALANCE_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Menu > Balance", string, "Close", "Back");
		    }
		    else if(listitem == 1)
		    {
		        return ShowPlayerDialog(playerid, BANK_WITHDRAW_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Bank Menu > Withdraw", "{FFFFFF}Please enter the amount you want to withdraw below:", "Enter", "Back");
		    }
		    else if(listitem == 2)
		    {
		        return ShowPlayerDialog(playerid, BANK_DEPOSIT_DIALOG, DIALOG_STYLE_INPUT, "{FFFFFF}Bank Menu > Deposit", "{FFFFFF}Please enter the amount you want to deposit below:", "Enter", "Back");
		    }
		    else if(listitem == 3)
		    {
		        format(string, sizeof(string), "{FFFFFF}Debt: $%d", AccountData[playerid][account_debt]);
		        return ShowPlayerDialog(playerid, BANK_DEBT_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Menu > Debt", string, "Pay", "Back");
		    }
		    else if(listitem == 4)
		    {
		        return ShowPlayerDialog(playerid, BANK_LOANS_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Menu > Loans", "{FFFFFF}Budget Loan ($500K)\nEconomy Loan ($1M)\nBusiness Loan ($5M)\nInvestment Loan ($10M)", "Apply", "Back");
		    }
	    }
	}
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(checkpointid == ServerData[server_menu])
	{
	  	return ShowBankMenu(playerid);
	}
	else
	{
		for(new i = 0; i < MAX_BANKS; i++)
		{
		    if(BankData[i][bank_active] == true)
			{
			    if(checkpointid == BankData[i][bank_entry])
			    {
			        SetPlayerVirtualWorld(playerid, i);
			        SetPlayerInterior(playerid, BANK_SPAWN_INT);
			        SetPlayerPos(playerid, BankData[i][bank_intx], BankData[i][bank_inty], BankData[i][bank_intz]);
			        SetPlayerFacingAngle(playerid, BankData[i][bank_inta]);
			        return SetCameraBehindPlayer(playerid);
			    }
			    else if(checkpointid == BankData[i][bank_exit])
			    {
			        SetPlayerVirtualWorld(playerid, 0);
			        SetPlayerInterior(playerid, 0);
			        SetPlayerPos(playerid, BankData[i][bank_spawnx], BankData[i][bank_spawny], BankData[i][bank_spawnz]);
			      	SetPlayerFacingAngle(playerid, BankData[i][bank_spawna]);
			        return SetCameraBehindPlayer(playerid);
			    }
			}
		}
	}
	return 1;
}

CMD:bankcommands(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: You do not have access to this command.");
	SendClientMessage(playerid, SERVER, "COMMANDS: /createbank, /deletebank, /editbank");
	return 1;
}

CMD:createbank(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: You do not have access to this command.");
	if(GetFreeBankSlot() == -1) return SendClientMessage(playerid, ERROR, "ERROR: There are no free bank slots. Increase MAX_BANKS");
	if(IsPlayerInRangeOfBank(playerid, BANK_ZONE) != -1) return SendClientMessage(playerid, ERROR, "ERROR: You are too close to another bank, choose another location.");

	new query[256], name[64], Float:pos[4], bankid = GetFreeBankSlot();
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(playerid, pos[3]);
	
	BankData[bankid][bank_extx] = pos[0];
	BankData[bankid][bank_exty] = pos[1];
	BankData[bankid][bank_extz] = pos[2];

	GetXYBehindPlayer(playerid, pos[0], pos[1], 1.5);
	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	
	BankData[bankid][bank_spawnx] = pos[0];
	BankData[bankid][bank_spawny] = pos[1];
	BankData[bankid][bank_spawnz] = pos[2];
	BankData[bankid][bank_spawna] = - pos[3];
	
	BankData[bankid][bank_intx] = BANK_SPAWN_X;
	BankData[bankid][bank_inty] = BANK_SPAWN_Y;
	BankData[bankid][bank_intz] = BANK_SPAWN_Z;
	BankData[bankid][bank_inta] = BANK_SPAWN_A;
	
	BankData[bankid][bank_loans] = 1;
	
	for(new i = 0; i < sizeof(sa_zones); i++)
	{
		if(pos[0] >= sa_zones[i][zone_area][0] && pos[0] <= sa_zones[i][zone_area][3] && pos[1] >= sa_zones[i][zone_area][1] && pos[1] <= sa_zones[i][zone_area][4])
		{
			format(name, sizeof(name), "%s Bank", sa_zones[i][zone_name]);

			BankData[bankid][bank_name] = name;

			BankData[bankid][bank_label] = CreateDynamic3DTextLabel(name, SERVER, BankData[bankid][bank_extx], BankData[bankid][bank_exty], BankData[bankid][bank_extz], 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1, 10.0);
			BankData[bankid][bank_icon] = CreateDynamicMapIcon(BankData[bankid][bank_extx], BankData[bankid][bank_exty], BankData[bankid][bank_extz], 52, -1, -1, -1, -1, 250.0);

			BankData[bankid][bank_entry] = CreateDynamicCP(BankData[bankid][bank_extx], BankData[bankid][bank_exty], BankData[bankid][bank_extz], 1.0, -1, -1, -1, 5.0, -1, 1);
            BankData[bankid][bank_exit] = CreateDynamicCP(BANK_EXIT_X, BANK_EXIT_Y, BANK_EXIT_Z, 1.0, bankid, -1, -1, 5.0, -1, 1);

		  	format(query, sizeof(query), "INSERT INTO `BANKS` (`ID`, `NAME`, `EXTX`, `EXTY`, `EXTZ`, `SPAWNX`, `SPAWNY`, `SPAWNZ`, `SPAWNA`, `LOANS`) VALUES ('%d', '%s', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d')", bankid, name, BankData[bankid][bank_extx], BankData[bankid][bank_exty], BankData[bankid][bank_extz], BankData[bankid][bank_spawnx], BankData[bankid][bank_spawny], BankData[bankid][bank_spawnz], BankData[bankid][bank_spawna], BankData[bankid][bank_loans]);
			database_result = db_query(bank_database, query);
			db_free_result(database_result);
			
			BankData[bankid][bank_active] = true;
			break;
		}
	}
	return 1;
}

CMD:deletebank(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: You do not have access to this command.");
	
	new bankid = IsPlayerInRangeOfBank(playerid, 10.0);
	if(bankid == -1) return SendClientMessage(playerid, ERROR, "ERROR: You must be next to a bank entrance to use this command.");
	
	new query[128];
	format(query, sizeof(query), "SELECT `ID` FROM `BANKS` WHERE `ID` = '%d'", bankid);
	database_result = db_query(bank_database, query);
	if(db_num_rows(database_result))
	{
		db_free_result(database_result);
		
		format(query, sizeof(query), "DELETE FROM `BANKS` WHERE `ID` = '%d'", bankid);
	 	db_free_result(db_query(bank_database, query));
	 	
	 	DestroyDynamicMapIcon(BankData[bankid][bank_icon]);
		DestroyDynamicCP(BankData[bankid][bank_entry]);
		DestroyDynamicCP(BankData[bankid][bank_exit]);
		DestroyDynamic3DTextLabel(BankData[bankid][bank_label]);
	 	
		BankData[bankid][bank_active] = false;
	}
	return 1;
}

CMD:editbank(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, ERROR, "ERROR: You do not have access to this command.");

	new bankid = IsPlayerInRangeOfBank(playerid, 10.0);
	if(bankid == -1) return SendClientMessage(playerid, ERROR, "ERROR: You must be next to a bank entrance to use this command.");

	new string[128];
	if(BankData[bankid][bank_loans] == 1)
	{
		format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Enabled", BankData[bankid][bank_name]);
	}
	else
	{
		format(string, sizeof(string), "{FFFFFF}Change Name: %s\nToggle Loans: Disabled", BankData[bankid][bank_name]);
	}

    AccountData[playerid][account_editing] = bankid;

	ShowPlayerDialog(playerid, BANK_EDIT_DIALOG, DIALOG_STYLE_LIST, "{FFFFFF}Bank Settings", string, "Edit", "Cancel");
	return 1;
}

