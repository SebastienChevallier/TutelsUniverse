#pragma strict

var heightMaps : RenderTexture[];
var fluxMaps : RenderTexture[];
var guiTex : RenderTexture;
var noiseShader : Shader;
var fluxShader : Shader;
var velocityShader : Shader;
var guiShader : Shader;

private var fluxMat : Material;
private var velocityMat : Material;
private var guiMat : Material;
private var idx : int = 0;

var octNum : int = 8;
var amp : float = 1.0;
var frq : float = 400.0;

function Start() 
{

	if(SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBFloat))
	{
		heightMaps[0].format = RenderTextureFormat.ARGBFloat;
		heightMaps[1].format = RenderTextureFormat.ARGBFloat;
		fluxMaps[0].format = RenderTextureFormat.ARGB32;
		fluxMaps[1].format = RenderTextureFormat.ARGB32;
	}
	else if(SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf))
	{
		print("Looks like your graphics card does not support 32 bit floating point textures. Simulation my contain artfacts.");
		heightMaps[0].format = RenderTextureFormat.ARGBHalf;
		heightMaps[1].format = RenderTextureFormat.ARGBHalf;
		fluxMaps[0].format = RenderTextureFormat.ARGBHalf;
		fluxMaps[1].format = RenderTextureFormat.ARGBHalf;;
	}
	else
	{
		print("Looks like your graphics card does not support floating point textures. Simulation my contain artfacts.");
	}
	
	//rough way to get unique seed each time program runs
	var seed = Time.realtimeSinceStartup * 1000.0;

    var perlin = new PerlinNoise(seed);
 	perlin.LoadPermTableIntoTexture();
   	perlin.RenderIntoTexture(noiseShader, heightMaps[0], octNum, frq, amp);
   	
   	fluxMat = new Material(fluxShader);
   	velocityMat = new Material(velocityShader);
   	guiMat = new Material(guiShader);

   	fluxMat.SetFloat("_TexSize", fluxMaps[0].width);
   	velocityMat.SetFloat("_TexSize", fluxMaps[0].width);
   		
}

function Update()
{
	var idx0 : int = idx % 2;
	var idx1 : int = (idx+1) % 2;
	
	fluxMat.SetTexture("_HtTex", heightMaps[idx0]);
	Graphics.Blit(fluxMaps[idx0], fluxMaps[idx1], fluxMat);
	
	velocityMat.SetTexture("_FluxTex", fluxMaps[idx1]);
	Graphics.Blit(heightMaps[idx0], heightMaps[idx1], velocityMat);
	
	Graphics.Blit(heightMaps[idx1], guiTex, guiMat);
	
	idx++;
}











