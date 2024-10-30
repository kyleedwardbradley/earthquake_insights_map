This is an interactive Leaflet map showing geotagged posts and 3D models for the [Earthquake Insights](https://earthquakeinsights.substack.com/) Substack.

Website: [here
](https://kyleedwardbradley.github.io/earthquake_insights_map/)

Technical details:

The URL of our specific Substack is hard-coded. Change this if you fork your own copy.

The Free vs. Paid status of posts is calculated to match our one-month paywall. 

Post data are stored in a GeoJSON file, "posts_final.geojson" in the root folder with the following format:

```
{
"type": "FeatureCollection",
	"features": [
  {
    "type": "Feature",
    "geometry": {
      "type": "Point",
      "coordinates": [-117.07,36.6]
    },
    "properties": {
      "size": "large",                 <---- ignored
      "date": "2024-10-25T00:00:00",   <---- ISO8601 time
      "url": "none",                   <---- Substack post url for post point, "none" for 3D model point
      "status": "paid",                <---- we only use this when it says "always" 
      "uid": "47e49522f2a04306af0d411f95c09e04",   <---- Sketchfab model UID
      "title": "Earthquakes in Death Valley"   <---- Title for 3D model point
    }
  },
  ... more posts go here
  ]
  }
}
```


Kyle Bradley, Earthquake Insights 2024
