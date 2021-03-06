// UI library
class Vector {
	public double x, y;

	public Vector(double vx, double vy){ setxy(vx, vy); }
	public void set(Vector v){ setxy(v.x, v.y); }
	public void setxy(double vx, double vy){ x = vx.clone; y = vy.clone; }

	public Vector add(Vector b) { return new Vector(x + b.x, y + b.y); }
	public Vector sub(Vector b) { return new Vector(x - b.x, y - b.y); }
	public double length(){ return Math.sqrt(x*x + y*y); }
	public double length2(){ return x*x + y*y; }

	public double dot(Vector b){ return x * b.x + y * b.y; }

	public void reflect(Vector normal){
		double d = dot(normal);
		x = x - 2.0 * d * normal.x;
		y = y - 2.0 * d * normal.y;
	}

	public Vector normal(){
		double len = length();
		return new Vector(x / len, y / len);
	}

	public Vector scale(double s) { return new Vector(s*x, s*y); }
	public Vector flip(){ return new Vector(-x, -y); }
}

class Mouse {
	Vector position(){
		Point xy = MouseInfo.getPointerInfo().getLocation();
		return new Vector(xy.x, xy.y);
	}
}

context Display {
	private Panel panel_;
	private Frame frame_;
	private Vector size_;
	private Mouse mouse_;

	private Vector offset_;

	public Display(){
		mouse_ = new Mouse();

		size_ = new Vector(640.0, 480.0);
		offset_ = new Vector(0.0, 0.0);
		panel_ = new Panel();

		frame_ = new Frame("");
		frame_.add("Center", panel_);
		frame_.resize(floor(size_.x) + 20, floor(size_.y) + 40);

		frame_.setVisible(true);
	}

	public Vector size() { return size_; }
	public Vector offset() { return offset_; }
	public Mouse mouse() { return mouse_; }

	public void clear()   { panel_.clear(); }
	public void repaint() { panel_.repaint(); }

	public void fg(Color color) { panel_.setColor(color); }

	private int floor(double v){ return v.toInteger(); }

	public void rect(Vector center, Vector halfsize) {
		panel_.fillRect(
			floor(center.x - halfsize.x + offset_.x),
			floor(center.y - halfsize.y + offset_.y),
			floor(2.0*halfsize.x),
			floor(2.0*halfsize.y));
	}
	public void oval(Vector center, Vector halfsize) {
		panel_.fillOval(
			floor(center.x - halfsize.x + offset_.x),
			floor(center.y - halfsize.y + offset_.y),
			floor(2.0*halfsize.x),
			floor(2.0*halfsize.y));
	}
	public void circle(Vector center, double radius) {
		panel_.fillOval(
			floor(center.x-radius + offset_.x),
			floor(center.y-radius + offset_.y),
			floor(2.0*radius),
			floor(2.0*radius));
	}
}

// Game implementation

interface Entity {
	public Body body();

	public void trigger_collision(World world, Entity e);
	public void trigger_Ball(World world, Ball e);
	public void trigger_Wall(World world, Wall e);
	public void trigger_Block(World world, Block e);
	public void trigger_Paddle(World world, Paddle e);
}

class Body {
	public Vector center;
	public Vector halfsize;
	public Vector velocity;
	public double mass;
	public int shape; // 0 = circle, 1 = rectangle
	public boolean static;

	public Body(){
		center = new Vector(0.0, 0.0);
		halfsize = new Vector(1.0, 1.0);
		velocity = new Vector(0.0, 0.0);
		mass = halfsize.x * halfsize.y * 4;
		shape = 1;
		static = false;
	}

	// only valid when shape == 0
	public double radius() const { return halfsize.x; }

	public double x() const { return center.x; }
	public double y() const { return center.y; }

	public double width()  const { return 2.0 * halfsize.x; }
	public double height() const { return 2.0 * halfsize.y; }

	public double left()   const { return center.x - halfsize.x; }
	public double right()  const { return center.x + halfsize.x; }
	public double top()    const { return center.y - halfsize.y; }
	public double bottom() const { return center.y + halfsize.y; }
}

class Ball implements Entity {
	public Ball(){
		body_ = new Body();
		body_.shape = 0;
		body_.static = false;
		body_.halfsize.setxy(10.0, 10.0);
	}

	private Body body_;
	public Body body(){ return body_; }

	public void trigger_collision(World world, Entity e) {     e.trigger_Ball(world, this);    }
	public void trigger_Ball(World world, Ball e)        { world.trigger_Ball_Ball(this, e);   }
	public void trigger_Wall(World world, Wall e)        { world.trigger_Ball_Wall(this, e);   }
	public void trigger_Block(World world, Block e)      { world.trigger_Ball_Block(this, e);  }
	public void trigger_Paddle(World world, Paddle e)    { world.trigger_Ball_Paddle(this, e); }
}

class Block implements Entity {
	public Block(){
		body_ = new Body();
		body_.shape = 1;
		body_.static = true;
		body_.halfsize.setxy(30.0, 10.0);
	}

	private Body body_;
	public Body body(){ return body_; }

	public void trigger_collision(World world, Entity e) {     e.trigger_Block(world, this);    }
	public void trigger_Ball(World world, Ball e)        { world.trigger_Block_Ball(this, e);   }
	public void trigger_Wall(World world, Wall e)        { world.trigger_Block_Wall(this, e);   }
	public void trigger_Block(World world, Block e)      { world.trigger_Block_Block(this, e);  }
	public void trigger_Paddle(World world, Paddle e)    { world.trigger_Block_Paddle(this, e); }
}

class Wall implements Entity {
	public boolean deadly;

	public Wall(){
		body_ = new Body();
		body_.shape = 1;
		body_.static = true;
		body_.halfsize.setxy(10.0, 10.0);

		deadly = false;
	}

	private Body body_;
	public Body body(){ return body_; }

	public void trigger_collision(World world, Entity e) {     e.trigger_Wall(world, this);    }
	public void trigger_Ball(World world, Ball e)        { world.trigger_Wall_Ball(this, e);   }
	public void trigger_Wall(World world, Wall e)        { world.trigger_Wall_Wall(this, e);   }
	public void trigger_Block(World world, Block e)      { world.trigger_Wall_Block(this, e);  }
	public void trigger_Paddle(World world, Paddle e)    { world.trigger_Wall_Paddle(this, e); }
}

class Paddle implements Entity {
	public Paddle(){
		body_ = new Body();
		body_.shape = 1;
		body_.static = true;
		body_.halfsize.setxy(30.0, 10.0);
	}

	private Body body_;
	public Body body(){ return body_; }

	public void trigger_collision(World world, Entity e) {     e.trigger_Paddle(world, this);    }
	public void trigger_Ball(World world, Ball e)        { world.trigger_Paddle_Ball(this, e);   }
	public void trigger_Wall(World world, Wall e)        { world.trigger_Paddle_Wall(this, e);   }
	public void trigger_Block(World world, Block e)      { world.trigger_Paddle_Block(this, e);  }
	public void trigger_Paddle(World world, Paddle e)    { world.trigger_Paddle_Paddle(this, e); }
}

context State {
	private Paddle       paddle_;
	private List<Ball>   balls_;
	private List<Block>  blocks_;
	private List<Wall>   walls_;
	private List<Entity> all_;

	public Paddle       paddle() const { return paddle_; }
	public List<Ball>   balls()  const { return balls_; }
	public List<Block>  blocks() const { return blocks_; }
	public List<Wall>   walls()  const { return walls_; }
	public List<Entity> all()    const { return all_; }

	public State(){
		balls_  = new List<Ball>();
		blocks_ = new List<Block>();
		walls_  = new List<Wall>();
		all_    = new List<Entity>();

		paddle_ = new Paddle();
		paddle_.body.static = true;
		all_.add(paddle_);
	}

	public void spawn_ball(Vector center, Vector velocity){
		Ball ball = new Ball();
		ball.body.center = center;
		ball.body.velocity = velocity;
		balls_.add(ball);
		all_.add(ball);
	}

	public void spawn_block(Vector center, Vector halfsize){
		Block block = new Block();
		block.body.center = center;
		block.body.halfsize = halfsize;
		blocks_.add(block);
		all_.add(block);
	}

	public void spawn_wall(Vector center, Vector halfsize, boolean deadly){
		Wall wall = new Wall();
		wall.body.center = center;
		wall.body.halfsize = halfsize;
		wall.deadly = deadly;
		walls_.add(wall);
		all_.add(wall);
	}

	public void remove_Ball(Ball entity){
		balls_.remove(entity);
		all_.remove(entity);
	}

	public void remove_Wall(Wall entity){
		walls_.remove(entity);
		all_.remove(entity);
	}

	public void remove_Block(Block entity){
		blocks_.remove(entity);
		all_.remove(entity);
	}
}

// Physics system
interface CollisionHandler {
	public void onCollision(Entity A, Entity B);
}

class Collision {
	public Entity A;
	public Entity B;

	public Collision(Entity a, Entity b){
		A = a;
		B = b;
	}
}

context Physics {
	public Physics(State state, CollisionHandler handler, Display display){
		Entities = state;
		Debug = display;
		Handler = handler;
	}

	public void update(double dt){
		Entities.integrate(dt * 0.5);
		Entities.collide(dt);
		Entities.integrate(dt * 0.5);
	}

	stageprop Entities {
		public void integrate(double dt){
			List<Entity> entities = all();
			for(Entity entity: entities){
				Body body = entity.body();
				if(!body.static){
					Integrator.step(dt, body.center, body.velocity);
				}
			}
		}

		public void collide(double dt){
			List<Collision> collisions = new List<Collision>();

			List<Entity> entities = all();
			for(int i = 0; i < entities.size; i++){
				Entity A = entities.get(i);
				Body a = A.body();
				for(int k = i + 1; k < entities.size; k++){
					Entity B = entities.get(k);
					Body b = B.body();

					if(Resolve.collision(a, b)){
						collisions.add(new Collision(A, B));
					}
				}
			}

			for(Collision collision: collisions){
				Handler.collide(collision.A, collision.B);
			}
		}
	} requires {
		public List<Entity> all() const;
	}

	role Handler {
		public void collide(Entity A, Entity B){
			onCollision(A, B);
		}
	} requires {
		public void onCollision(Entity A, Entity B);
	}

	role Resolve {
		public boolean collision(Body a, Body b){
			if(a.static && b.static){
				return false;
			}

			if(!aabb_intersect(a, b)){
				return false;
			}

			if(a.shape == 0){ // circle
				if(b.shape == 0){
					return circle_circle(a, b);
				}
				return circle_aabb(a, b);
			} else {
				if(b.shape == 0){
					return circle_aabb(b, a);
				}
			}

			return aabb_aabb(a, b);
		}

		public boolean aabb_intersect(Body a, Body b){
			return (Math.abs(a.center.x - b.center.x) < (a.halfsize.x + b.halfsize.x)) &&
				(Math.abs(a.center.y - b.center.y) < (a.halfsize.y + b.halfsize.y));
		}

		public boolean circle_circle(Body a, Body b){
			Vector delta = a.center.sub(b.center);
			if(delta.length >= a.radius + b.radius){
				return false;
			}

			Debug.point(a.center.add(b.center).scale(0.5));

			// remove penetration
			Vector penetration = delta.normal.scale(a.radius + b.radius - delta.length);

			double ra = a.mass / (a.mass + b.mass);
			double rb = b.mass / (a.mass + b.mass);

			if(a.static){
				ra = 1.0;
				rb = 0.0;
			} else if (b.static) {
				ra = 0.0;
				rb = 1.0;
			}

			a.center = a.center.add(penetration.scale(rb));
			b.center = b.center.add(penetration.scale(ra));

			// momentum transfer
			Vector normal = delta.normal;
			double p = 2.0 * (a.velocity.dot(normal) - b.velocity.dot(normal)) / (a.mass + b.mass);

			Vector av = a.velocity.sub(normal.scale(p * a.mass));
			Vector bv = b.velocity.add(normal.scale(p * b.mass));

			a.velocity.set(av);
			b.velocity.set(bv);

			return true;
		}

		public boolean circle_aabb(Body circle, Body rect){
			// circle is circle, rect is rect
			if(circle.static || !rect.static){
				// TODO: implement properly
				return true;
			}

			Vector closest = new Vector(
				clamp(circle.x, rect.left, rect.right),
				clamp(circle.y, rect.top, rect.bottom));

			Vector delta = circle.center.sub(closest);
			if(delta.length >= circle.radius){
				return false;
			}

			Debug.point(closest);
			Vector penetration = delta.normal.scale(circle.radius - delta.length);
			circle.center = circle.center.add(penetration);
			circle.velocity.reflect(delta.normal);

			return true;
		}

		public boolean aabb_aabb(Body a, Body b){
			// TODO: implement
			return true
		}

		private double clamp(double v, double min, double max){
			if(v < min){ return min; }
			if(v > max){ return max; }
			return v;
		}
	}

	role Integrator {
		public void step(double dt, Vector position, Vector velocity){
			position.x = position.x + velocity.x * dt;
			position.y = position.y + velocity.y * dt;
		}
	}

	role Debug {
		public void point(Vector p){
			fg(new Color(255, 0, 0));
			circle(p, 3.0);
		}
	} requires {
		public void fg(Color color);
		public void circle(Vector center, double radius);
	}
}

// Render system
context Render {
	public Render(State state, Display display){
		Entities = state;
		Canvas = display;
	}

	stageprop Entities {
		public void render(){
			for(Wall wall: walls()){
				Canvas.wall(wall);
			}
			for(Block block: blocks()){
				Canvas.block(block);
			}
			for(Ball ball: balls()){
				Canvas.ball(ball);
			}

			Canvas.paddle(paddle());
		}
	} requires {
		public Paddle paddle() const;
		public List<Ball> balls() const;
		public List<Wall> walls() const;
		public List<Block> blocks() const;
	}

	role Canvas {
		public void ball(Ball ball){
			body(new Color(144, 195, 212), ball.body);
		}

		public void block(Block block){
			body(new Color(212, 195, 144), block.body);
		}

		public void wall(Wall wall){
			if(wall.deadly) {
				body(new Color(255, 0, 0), wall.body);
			} else {
				body(new Color(212, 144, 195), wall.body);
			}
		}

		public void paddle(Paddle paddle){
			body(new Color(144, 212, 195), paddle.body);
		}

		private void body(Color color, Body body){
			fg(color);
			if(body.shape == 0){
				circle(body.center, body.radius);
			} else {
				rect(body.center, body.halfsize);
			}
		}
	} requires {
		public Vector size();
		public void fg(Color color);
		public void rect(Vector center, Vector halfsize);
		public void circle(Vector center, double radius);
	}

	public void render(){
		Entities.render();
	}
}

context World implements CollisionHandler {
	private State   state_;
	private Display display_;
	private Physics physics_;
	private Render  render_;

	private double shake;

	public World(Display display){
		display_ = display;

		state_ = new State();
		//TODO: this should use debug layer instead of display
		physics_ = new Physics(state_, this, display_);
		render_ = new Render(state_, display_);

		shake = 0.0;
	}

	public void step(double dt){
		display_.clear();

		if(shake > 0){
			display_.offset.set(display_.offset.scale(0.1).add(
				new Vector(
					shake * Math.random() * 10.0,
					shake * Math.random() * 10.0
				)));
			shake = shake - dt;
		} else {
			display_.offset.setxy(0.0, 0.0);
		}

		state_.paddle.body.center.x = display_.mouse.position.x.clone;

		render_.render();
		physics_.update(dt);

		display_.repaint();
	}

	public void load(/* level */){
		//TODO: load from file
		double wallsize = 20.0;

		// setup paddle
		state_.paddle.body.center.setxy(
			display_.size.x/2.0,
			display_.size.y - wallsize - state_.paddle.body.halfsize.y);

		// setup ball
		double cx = state_.paddle.body.center.x.clone;
		double cy = state_.paddle.body.center.y - 20.0;

		state_.spawn_ball(new Vector(cx+10.0,cy), new Vector(100.0, -100.0));
		state_.spawn_ball(new Vector(cx-10.0,cy), new Vector(-90.0, -100.0));

		// spawn walls
		state_.spawn_wall(
			new Vector(0.0, display_.size.y/2.0),
			new Vector(wallsize, display_.size.y/2.0),
			false
		);
		state_.spawn_wall(
			new Vector(display_.size.x, display_.size.y/2.0),
			new Vector(wallsize, display_.size.y/2.0),
			false
		);
		state_.spawn_wall(
			new Vector(display_.size.x/2.0, 0.0),
			new Vector(display_.size.x/2.0, wallsize),
			false
		);
		state_.spawn_wall(
			new Vector(display_.size.x/2.0, display_.size.y),
			new Vector(display_.size.x/2.0, wallsize),
			true
		);

		// setup blocks
		Vector blocksize = new Vector(30.0, 10.0);

		double left = wallsize + 10.0;
		double right = display_.size.x - wallsize - 10.0;

		int count = ((right - left) / (blocksize.x * 2)).toInteger();
		double width = (right - left) / count;

		double y = wallsize * 3.0;
		for(int row = 0; row < 3; row++){
			double x = left + width / 2;
			for(int i = 0; i < count; i++){
				state_.spawn_block(
					new Vector(x, y),
					blocksize
				);
				x = x + width;
			}
			y = y + blocksize.y * 2 + 10.0;
		}
	}

	public void onCollision(Entity A, Entity B){
		shake = shake + 0.2;
		if(shake > 1.0){
			shake = 1.0;
		}
		A.trigger_collision(this, B);
	}

	public void trigger_Ball_Ball(Ball a, Ball b){}
	public void trigger_Ball_Wall(Ball a, Wall b){ if(b.deadly){ state_.remove_Ball(a); } }
	public void trigger_Ball_Block(Ball a, Block b){ state_.remove_Block(b); }
	public void trigger_Ball_Paddle(Ball a, Paddle b){ }
	public void trigger_Block_Ball(Block a, Ball b){ trigger_Ball_Block(b, a) }
	public void trigger_Block_Wall(Block a, Wall b){}
	public void trigger_Block_Block(Block a, Block b){}
	public void trigger_Block_Paddle(Block a, Paddle b){}
	public void trigger_Wall_Ball(Wall a, Ball b){ trigger_Ball_Wall(b, a) }
	public void trigger_Wall_Wall(Wall a, Wall b){}
	public void trigger_Wall_Block(Wall a, Block b){}
	public void trigger_Wall_Paddle(Wall a, Paddle b){}
	public void trigger_Paddle_Ball(Paddle a, Ball b){ trigger_Ball_Paddle(b, a); }
	public void trigger_Paddle_Wall(Paddle a, Wall b){}
	public void trigger_Paddle_Block(Paddle a, Block b){}
	public void trigger_Paddle_Paddle(Paddle a, Paddle b){}

}

context Breakout {
	private Display display_;
	private World world_;

	public Breakout(){
		display_ = new Display();
		world_ = new World(display_);
	}

	public void run(){
		world_.load();
		while(true){
			//TODO: use wall clock for timing
			double dt = 0.033;
			world_.step(dt);
			Thread.sleep(16);
		}
	}
}

new Breakout().run()

