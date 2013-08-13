import java.util.concurrent.Semaphore;

class Flock {
  ArrayList<Boid> boids;
  ArrayList<Boid> enterQueue;
  Semaphore lock;
  
  Flock() {
    this.boids = new ArrayList<Boid>();
    this.enterQueue = new ArrayList<Boid>();
    this.lock = new Semaphore(1);
  }
  
  void addBoid(Boid boid) {
    try {
      this.lock.acquire();
      this.enterQueue.add(boid);
      this.lock.release();
    } catch (InterruptedException e) {
      println("interrupted in addBoid");
    }
  }
  
  void update() {
    try {
      this.lock.acquire();
      for (Boid boid : this.enterQueue) {
        this.boids.add(boid);
      }
      this.enterQueue = new ArrayList<Boid>();
      this.lock.release();
    } catch (InterruptedException e) {
      println("interrupted in update");
    }

    for (Boid boid : this.boids) {
      boid.updateThrust();
    }
    for (Boid boid : this.boids) {
      boid.update();
    }
    for (int i = boids.size()-1; i>=0; i--) {
      Boid boid = boids.get(i);
      if (boid.isDead()) {
        boids.remove(i);
      }
    }
  }
}
