// Stats for Tac Tac Stage

{
	spriteContent: self.getResource().getContent("tactac"),
	animationId: "stage",
	ambientColor: 0x20fd8eff,
	shadowLayers: [
		{
			id: "0",
			maskSpriteContent: self.getResource().getContent("tactac"),
			maskAnimationId: "shadowMaskFront",
			color:0x40000000,
			foreground: true
		},
		{
			id: "1",
			maskSpriteContent: self.getResource().getContent("tactac"),
			maskAnimationId: "shadowMask",
			color:0x40000000,
			foreground: false
		}
	],
	camera: {
		startX : 0,
		startY : 43,
		zoomX : 0,
		zoomY : 0,
		camEaseRate : 1 / 11,
		camZoomRate : 1 / 15,
		minZoomHeight : 360,
		initialHeight: 360,
		initialWidth: 640,
		backgrounds: [
			// Sky
			{
				spriteContent: self.getResource().getContent("tactac"),
				animationId: "bg_reg",
				mode: ParallaxMode.BOUNDS,
				originalBGWidth: 960,
				originalBGHeight: 415,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0.06,
				yPanMultiplier: 0.06,
				scaleMultiplier: 1,
				foreground: false,
				depth: 0
			},
			// {
			// 	spriteContent: self.getResource().getContent("tactac"),
			// 	animationId: "Light",
			// 	mode: ParallaxMode.DEPTH,
			// 	originalBGWidth: 1920,
			// 	originalBGHeight: 1000,
			// 	horizontalScroll: true,
			// 	verticalScroll: false,
			// 	loopWidth: 0,
			// 	loopHeight: 0,
			// 	xPanMultiplier: 0.135,
			// 	yPanMultiplier: 0.135,
			// 	scaleMultiplier: 1,
			// 	foreground: false,
			// 	depth: -25
			// },
			{
				spriteContent: self.getResource().getContent("tactac"),
				animationId: "L2",
				mode: ParallaxMode.DEPTH,
				originalBGWidth: 2050,
				originalBGHeight: 1000,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0,
				yPanMultiplier: 0.135,
				scaleMultiplier: 1,
				foreground: true,
				depth: -20
			},
			{
				spriteContent: self.getResource().getContent("tactac"),
				animationId: "L1",
				mode: ParallaxMode.DEPTH,
				originalBGWidth: 2050,
				originalBGHeight: 1000,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0,
				yPanMultiplier: 0,
				scaleMultiplier: 1,
				foreground: false,
				depth: 70
			},
			// {
			// 	spriteContent: self.getResource().getContent("tactac"),
			// 	animationId: "Lantern",
			// 	mode: ParallaxMode.DEPTH,
			// 	originalBGWidth: 2050,
			// 	originalBGHeight: 1000,
			// 	horizontalScroll: false,
			// 	verticalScroll: false,
			// 	loopWidth: 0,
			// 	loopHeight: 0,
			// 	xPanMultiplier: 0,
			// 	yPanMultiplier: 0.135,
			// 	scaleMultiplier: 1,
			// 	foreground: false,
			// 	depth: 7
			// },
			{
				spriteContent: self.getResource().getContent("tactac"),
				animationId: "Fence",
				mode: ParallaxMode.DEPTH,
				originalBGWidth: 2050,
				originalBGHeight: 1000,
				horizontalScroll: false,
				verticalScroll: false,
				loopWidth: 0,
				loopHeight: 0,
				xPanMultiplier: 0,
				yPanMultiplier: 0.135,
				scaleMultiplier: 1,
				foreground: false,
				depth: 125
			},

			// {
			// 	spriteContent: self.getResource().getContent("tactac"),
			// 	animationId: "bg_image_magenta",
			// 	mode: ParallaxMode.DEPTH,
			// 	originalBGWidth: 960,
			// 	originalBGHeight: 415,
			// 	horizontalScroll: true,
			// 	verticalScroll: false,
			// 	loopWidth: 960,
			// 	loopHeight: 0,
			// 	xPanMultiplier: 0.06,
			// 	yPanMultiplier: 0.06,
			// 	scaleMultiplier: 1,
			// 	foreground: false,
			// 	depth: 5
			// },
		// 	// Clouds
		// 	{
		// 		spriteContent: self.getResource().getContent("tactac"),
		// 		animationId: "cloud_back",
		// 		mode: ParallaxMode.DEPTH,
		// 		originalBGWidth: 1542,
		// 		originalBGHeight: 93,
		// 		horizontalScroll: true,
		// 		verticalScroll: false,
		// 		loopWidth: 0,
		// 		loopHeight: 0,
		// 		xPanMultiplier: 0.135,
		// 		yPanMultiplier: 0.135,
		// 		scaleMultiplier: 1,
		// 		foreground: false,
		// 		depth: 2500
		// 	},
		// 	// Clouds 2
		// 	{
		// 		spriteContent: self.getResource().getContent("tactac"),
		// 		animationId: "cloud_back_2",
		// 		mode: ParallaxMode.DEPTH,
		// 		originalBGWidth: 1542,
		// 		originalBGHeight: 93,
		// 		horizontalScroll: true,
		// 		verticalScroll: false,
		// 		loopWidth: 0,
		// 		loopHeight: 0,
		// 		xPanMultiplier: 0.135,
		// 		yPanMultiplier: 0.135,
		// 		scaleMultiplier: 1,
		// 		foreground: false,
		// 		depth: 1750
		// 	}
		]
	}
}
