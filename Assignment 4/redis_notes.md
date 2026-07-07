# Why caching improves application performance
Integrating an in-memory caching layer like Redis dramatically enhances application speed and scalability due to the following core factors:

1. **Sub-Millisecond Latency (In-Memory Storage)**

   Redis stores its data entirely in RAM. Because reading from memory is orders of magnitude faster than reading from a disk, data retrieval happens instantly with sub-millisecond latency.
2. **Drastic Reduction in Database Load**

   By serving the data directly from the cache (Cache Hit), the primary database is completely bypassed for that request. This preserves database resources for critical write transactions and complex analytical operations.
3. **Bypassing Computationally Expensive Operations**

   The application can perform the heavy computation once, save the finalized payload inside Redis, and effortlessly serve that exact result to subsequent users until the TTL expires.
4. **Intelligent Data Lifecycles (TTL)**

    Using Time-To-Live (TTL) prevents the cache from serving stale, outdated information indefinitely. Once the EXPIRE timer runs out, the data self-deletes.

# Redis use cases

**1. Caching (Session & Data)**

**2. Real-Time Leaderboards (Sorted Sets)**

**3. Message Brokers & Queues (Pub/Sub & Lists)**

**4. Rate Limiting**

**5. Geospatial Indexing**
