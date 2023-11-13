  import processing.svg.*;

  PImage input;
  String input_name = "input.jpg";
  
  int nr_layers = 6; // number of layers
  PImage[] output_layers = new PImage[nr_layers];
  float v_line_offset = 5.0; // distance between lines in hatching pattern
  float blur_radius = 2.0; // radius of gaussian blur applied to image

  int input_width = 1152;
  int input_height = 864;
  
  boolean save = false;

void setup () {
  // set dimensions of canvas
  size(1152, 864);
  tint(255, 64);
  background(255);
  
  // load and set input image
  input = loadImage(sketchPath() + "\\" + input_name);
  
  // create the crosshatch layers in a loop:
  for ( int i = 0; i < nr_layers; i++ ) {
    // nr_layers thresholds are equidistantly chosen between 0 and 1 (exclusive)
    // e.g. for 4 layers: 0.2, 0.4, 0.6, 0.8
    float my_thresh = 1.0 / ((float) nr_layers + 1) * (i + 1);
    
    // the angles are equidistantly chosen between 0 and pi (including 0)
    // e.g. for 4 layers: 0.0, PI/4, PI/2, 3PI/4
    float my_theta = PI / nr_layers * i;
    
    // create a new layer with the appropriate threshold and angle values
    output_layers[i] = create_layer( my_thresh, my_theta );
    
    // draw the layer and, if save == true, record this and save it as svg 
    if (save) {
      // start svg recording for this specific layer
      beginRecord(SVG, "output_layers/layer_" + i + ".svg");
      image(output_layers[i], 0, 0);
      // end svg recording
      endRecord();
    } else {
      image(output_layers[i], 0, 0);
    }
    
  }
  
}

// function for create one crosshatch layer
// thresh: threshold value (based on pixel brightness)
// theta: angle at which the lines of this layer will be drawn
PImage create_layer (float thresh, float theta) {
  print("Now creating layer with threshold:", thresh, "and angle:", theta, "\n");
  
  // create an ampty image with same dimensions as the input image
  // let mask image contain the filter data
  // apply transformations on thie copy of the original data to obtain a mask satisfying this threshold
  PImage mask = createImage(input_width, input_height, RGB);
  mask = input.copy();
  mask.filter(INVERT);
  mask.filter(BLUR, blur_radius);
  mask.filter(THRESHOLD, thresh);
  
  // create an empty graphics object
  // determine a local coordinate system (rotated around a translated origin), so that we can simply draw horizontal lines within the local system, which will be diagonal in the global system
  // will this layer will (locally) horizontal lines
  // apply the mask layer to the line layer
  PGraphics lines = createGraphics(input_width, input_height);
  lines.beginDraw();
  lines.background(255);
  lines.translate(input_width / 2, input_height / 2);
  lines.rotate(theta);
  for ( int i = -input_height; i < input_height; i += v_line_offset) {
    lines.line(-input_width, i, 2 * input_width, i);
  }
  lines.rotate(-theta);
  lines.mask(mask);
  lines.endDraw();
  
  // return the result
  return lines;
}
