
Map map;
ArrayList<Colony> colonies = new ArrayList<Colony>();
ArrayList<Food> foods=new ArrayList<Food>();

void setup(){
  fullScreen();
  map=new Map(50);
  frameRate(60);
}

void draw(){
  background(163, 114, 55);

  map.updatePheromones();
  map.render();

  for (int f=foods.size()-1;f>=0;f--){
    foods.get(f).render();
    if (foods.get(f).del){
      foods.remove(f);
    }
  }

  for (Colony c : colonies){
    c.update();
    c.render();
  }

  map.mouseControls();


  noStroke();
  textAlign(LEFT,TOP);
  textSize(30);
  fill(255,255,0);
  text(frameRate,0,0);
  fill(255,0,255);
  text(60/frameRate,0,30);
}

void keyPressed(){
  if (key=='n'){
    PVector p=map.stw(mouseX,mouseY);
    colonies.add(new Colony(p.x,p.y,1,500));
  }else if (key=='c'){
      colonies=new ArrayList<Colony>();
      map.clearMap();
  }
}

void mouseWheel(MouseEvent event) {
  map.mouseWheel(event);
}
