package;

import openfl.filters.BlurFilter;
import openfl.filters.ShaderFilter;
import openfl.display.DisplayObjectShader;
import openfl.display.Shader;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.geom.Point;
import openfl.utils.ByteArray;


class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		var bmData = Assets.getBitmapData ("assets/testimg.png");
		
		var filter = new BlurFilter(16, 16, 3);
		bmData.applyFilter(bmData, bmData.rect, new Point(0,0), filter);

		var bitmap = new Bitmap (bmData);
		// var shader = new CustomBlurShader();
		// var shader2 = new CustomBlurShader();

		// shader.data.directionX.value = [3.5];
		// shader.data.directionY.value = [0.0];
		// shader2.data.directionX.value = [0.0];
		// shader2.data.directionY.value = [3.5];
		// var shaderFilter = new ShaderFilter(shader);
		// var shader2Filter = new ShaderFilter(shader2);


		//bitmap.filters = [shaderFilter, shader2Filter];

		var full_filters:Array<openfl.filters.BitmapFilter> = [];
		for (i in 1...15) {
			var sh = new KawaseShader();
			sh.data.itern.value = [i];
			full_filters.push(new ShaderFilter(sh));
		}
		// bitmap.filters = [sf];
		// bitmap.filters = full_filters;
		addChild (bitmap);
		
		bitmap.x = (stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (stage.stageHeight - bitmap.height) / 2;
		
	}
	
	
}

class CustomShader extends DisplayObjectShader {

	public function new(code:ByteArray = null)
	{
		glFragmentSource = "

			varying float openfl_Alphav;
			varying vec4 openfl_ColorMultiplierv;
			varying vec4 openfl_ColorOffsetv;
			varying vec2 openfl_TextureCoordv;

			uniform sampler2D openfl_Texture;
			uniform vec2 openfl_TextureSize;
			void main(void){
				vec2 center = vec2(400.0, 400.0);
				float strength = 0.8;
				vec2 resolution = openfl_TextureSize;
				vec2 vUv = openfl_TextureCoordv;
				vec4 sum = vec4( 0. );

				vec2 toCenter = center - openfl_TextureCoordv * resolution;
				vec2 inc = toCenter * strength / resolution;
				float boost = 2.;

				inc = center / resolution - openfl_TextureCoordv;
				
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv - inc * 4. ) ) * 0.051;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv - inc * 3. ) ) * 0.0918;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv - inc * 2. ) ) * 0.12245;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv - inc * 1. ) ) * 0.1531;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv + inc * 0. ) ) * 0.1633;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv + inc * 1. ) ) * 0.1531;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv + inc * 2. ) ) * 0.12245;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv + inc * 3. ) ) * 0.0918;
				sum += texture2D( openfl_Texture, ( openfl_TextureCoordv + inc * 4. ) ) * 0.051;

				gl_FragColor = sum;
			}
		";
		super(code);
	}
	
}


class CustomBlurShader extends DisplayObjectShader {

	public function new(code:ByteArray = null)
	{
		glFragmentSource = "

			varying float openfl_Alphav;
			varying vec4 openfl_ColorMultiplierv;
			varying vec4 openfl_ColorOffsetv;
			varying vec2 openfl_TextureCoordv;

			uniform sampler2D openfl_Texture;
			uniform vec2 openfl_TextureSize;
			uniform float directionX;
			uniform float directionY;
			void main(void){
				vec2 direction = vec2(directionX, directionY);
	  			vec4 color = vec4(0.0);
				vec2 off1 = vec2(1.3846153846) * direction;
				vec2 off2 = vec2(3.2307692308) * direction;
				color += texture2D(openfl_Texture, openfl_TextureCoordv) * 0.2270270270;
				color += texture2D(openfl_Texture, openfl_TextureCoordv + (off1 / openfl_TextureSize)) * 0.3162162162;
				color += texture2D(openfl_Texture, openfl_TextureCoordv - (off1 / openfl_TextureSize)) * 0.3162162162;
				color += texture2D(openfl_Texture, openfl_TextureCoordv + (off2 / openfl_TextureSize)) * 0.0702702703;
				color += texture2D(openfl_Texture, openfl_TextureCoordv - (off2 / openfl_TextureSize)) * 0.0702702703;
				
				gl_FragColor = color;

			}
		";
		super(code);
	}
	
}

class KawaseShader extends DisplayObjectShader {
	

	public function new(code:ByteArray = null)
	{

		glFragmentSource = "

			varying float openfl_Alphav;
			varying vec4 openfl_ColorMultiplierv;
			varying vec4 openfl_ColorOffsetv;
			varying vec2 openfl_TextureCoordv;

			uniform sampler2D openfl_Texture;
			uniform vec2 openfl_TextureSize;
			uniform float itern;

		
		vec4 KawaseBlurFilter( sampler2D tex, vec2 texCoord, vec2 pixelSize, float iteration )
		{
			vec2 texCoordSample;
			vec2 halfPixelSize = pixelSize / 2.0;
			vec2 dUV = ( pixelSize.xy * vec2( iteration, iteration ) ) + halfPixelSize.xy;

			vec4 cOut = vec4(0.0);

			// Sample top left pixel
			texCoordSample.x = texCoord.x - dUV.x;
			texCoordSample.y = texCoord.y + dUV.y;
			
			cOut += texture2D( tex, texCoordSample );

			// Sample top right pixel
			texCoordSample.x = texCoord.x + dUV.x;
			texCoordSample.y = texCoord.y + dUV.y;

			cOut += texture2D( tex, texCoordSample );

			// Sample bottom right pixel
			texCoordSample.x = texCoord.x + dUV.x;
			texCoordSample.y = texCoord.y - dUV.y;
			cOut += texture2D( tex, texCoordSample );

			// Sample bottom left pixel
			texCoordSample.x = texCoord.x - dUV.x;
			texCoordSample.y = texCoord.y - dUV.y;

			cOut += texture2D( tex, texCoordSample );

			// Average 
			cOut = cOut * vec4(0.25, 0.25, 0.25, 0.25);
		
			return cOut;
		}

		void main(void){
			vec2 pixelSize = vec2(0.0001, 0.0001);
			float alpha = texture2D(openfl_Texture, openfl_TextureCoordv).a;
			gl_FragColor = vec4(KawaseBlurFilter(openfl_Texture, openfl_TextureCoordv, pixelSize, itern).xyz, alpha);
		}
		";

		super(code);
	}
}