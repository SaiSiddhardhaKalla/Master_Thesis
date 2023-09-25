
## 0. Libraries
library(tidyverse, quietly=T) #data wrangling
library(tidyr, quietly=T) #data wrangling
library(sf, quietly=T) #geospatial analysis
library(grid, quietly=T) #make grid
library(gridExtra, quietly=T) #make grid
library(raster, quietly=T) # import raster files
library(exactextractr, quietly=T) # zonal statistics
library(gganimate, quietly=T) # animation
library(classInt, quietly=T) #bins
library(gifski, quietly=T) #renderer
library(rfigshare)
library(rgdal)
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)
library(zoo)

## 1. SHAPEFILE
# define longlat projection
crsLONGLAT <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

#read shapefile
sub <- readOGR(
  #dsn= paste0(getwd()) ,
  dsn= normalizePath("/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/DataSets/MA/IN_villages/") ,
  layer="output_part_4",
  verbose=FALSE
)
# sub <- st_read("/Users/sid/Documents/maps-master/Village/TELANGANA.geojson")
#sub <- st_read("/Users/sid/Library/CloudStorage/OneDrive-DeakinUniversity/UDocs - D/Python/TS/Village_poly.geojson")


# shapefile df
sub2 = st_as_sf(sub)

# gr <- st_make_grid(sub2, cellsize = 25000, what = "polygons", square = F) %>%
#   st_intersection(sub2) %>%
#   st_sf() %>%
#   mutate(id = row_number())

gg <- sub2 %>% filter(
  st_geometry_type(.)
  %in% c("POLYGON", "MULTIPOLYGON")) %>% 
  mutate(id = row_number()) %>% # id no. required for merging df
  st_cast("MULTIPOLYGON") #transform to multipolygons

g <- st_transform(gg, crs = crsLONGLAT)

## 2. NIGHTLIGHT DATA
##list of all nightlight raster files from FigShare
# x = rfigshare::fs_details("9828827", mine = F, session = NULL)
# urls = jsonlite::fromJSON(jsonlite::toJSON(x$files), flatten = T)
# urls
# # download harmonized nightlight data for 1992-2020
# urls$download <- paste0(urls$download_url, "/", urls$name)
# urls <- urls[-28,] # get rid of the 2013 duplicate
# url <- urls[,5]
# for (u in url){
#   download.file(u, basename(u), mode="wb")
# }

# enlist raster files, merge them into a single file and re-project

rastfiles <- list.files(path = getwd(),
                        pattern = ".tif$",
                        all.files=T, 
                        full.names=F)
# rastfiles <- list.files(path = "/Users/sid/Documents/Night Lights/",

dd <- list()
# compute average nighlight DN values for every hexbin
for(i in rastfiles) dd[[i]] <- {
  allrasters <- raster(i)
  d  <- exact_extract(allrasters, g, 
                      "sum") #mean
  d
}

dd <- do.call(rbind, dd) # pull them all together
a <- as.data.frame(t(dd)) #convert to data.frame and transpose
a$id <- 1:max(nrow(a)) # id for joining with sf object
names(a) #check column names
# Check this before running
ee <- pivot_longer(a, cols=1:11, names_to = "year", values_to = "value") #wide to long format
l <- ee %>% # extract year from raster name
  mutate_at("year", str_replace_all, c("Harmonized_DN_NTL_"="", "_simVIIRS"="", "_calDMSP"="", ".tif"=""))
head(l)

f <- left_join(l, gg, by="id") %>% # join with transformed sf object
  st_as_sf() %>%
  filter(!st_is_empty(.)) #remove null features

# check var types
str(f)

# f$year <- as.numeric(as.character(f$year))
f$year <- as.Date(paste0(as.character(f$year), '01'), format='%Y%m%d') # change date type
class(f)

# drop geometry
ff <- f %>% st_drop_geometry()
class(ff)


fff <- ff %>% 
  mutate(year = str_c('', year)) %>%
  pivot_wider(names_from = year, values_from = c(value))
drop <- c("id","OBJECTID", "Shape_Leng", "Shape_Area","VILNAM_SOI",
          "STNAME","SDTNAME",'dtname',"vilname","NAME","STVIL","LOC_STAT_1",
          "STCODE11", "DTCODE11.x", "SDTCODE11", "VILCODE11", "VILNAME11.",
          "stcode11","dtcode11","year_stat","SHAPE_Leng","SHAPE_Area","OBJECTID","test","FID")
fff = fff[,!(names(fff) %in% drop)]
fff


# export csv
write.csv(fff,"IN_villages_22_4.csv",row.names = FALSE)


