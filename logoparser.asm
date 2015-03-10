.var	color
.var	fy
.var image = LoadPicture("data\logo.gif")
 .for (var y=0; y < 16 ;  y++)
    .for (var x=0; x < 32 ; x++) {
		.if (y > 7) .eval fy = y+4
			else	.eval fy = y
		.var byte = 0
		.for(var b=0; b < 8 ; b++) {
		        .eval color = image.getPixel(mod(x*16+b*2+410,512),mod([fy+1]*2,40))
				.if ([color&$ff]>50) .eval byte	= byte+[1<<[7-b]]
		}
		.byte	byte
	}
