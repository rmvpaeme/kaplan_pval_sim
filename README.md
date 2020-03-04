# kaplan_pval_sim
Code used for animated Kaplan Meier animated gif (https://twitter.com/RubenVanPaemel/status/1235255456307830784)

Kaplan Meier simulation code partially used from http://dwoll.de/rexrepos/posts/survivalKM.html#simulated-right-censored-event-times-with-weibull-distribution

to make the animation from the individual plots:

```
convert *png km.gif
convert -coalesce km.gif frames%04d.png
ffmpeg -r 10 -i frames%04d.png -vcodec h264 -y  movie.mp4
ffmpeg -i movie.mp4 -filter:v "setpts=3.0*PTS" movieslow.mp4
```
