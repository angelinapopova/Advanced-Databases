use bookstore;

// TASK 1. Data Generation — insert 30+ books

db.books.insertMany([
  { title: "Clean Code", author: "Robert C. Martin", category: "Programming", price: 35, in_stock: true, published_year: 2008, rating: 4.8 },
  { title: "The Pragmatic Programmer", author: "Andrew Hunt", category: "Programming", price: 42, in_stock: true, published_year: 1999, rating: 4.6 },
  { title: "Clean Architecture", author: "Robert C. Martin", category: "Programming", price: 38, in_stock: false, published_year: 2017, rating: 4.5 },
  { title: "Design Patterns", author: "Erich Gamma", category: "Programming", price: 45, in_stock: true, published_year: 1994, rating: 4.4 },
  { title: "Refactoring", author: "Martin Fowler", category: "Programming", price: 48, in_stock: true, published_year: 2018, rating: 4.7 },
  { title: "You Don't Know JS", author: "Kyle Simpson", category: "Programming", price: 25, in_stock: true, published_year: 2015, rating: 4.3 },
  { title: "Fluent Python", author: "Luciano Ramalho", category: "Programming", price: 39, in_stock: true, published_year: 2022, rating: 4.7 },
  { title: "Database Internals", author: "Alex Petrov", category: "Programming", price: 44, in_stock: true, published_year: 2019, rating: 4.6 },
  { title: "Sapiens", author: "Yuval Noah Harari", category: "History", price: 22, in_stock: true, published_year: 2011, rating: 4.7 },
  { title: "Homo Deus", author: "Yuval Noah Harari", category: "History", price: 24, in_stock: true, published_year: 2015, rating: 4.5 },
  { title: "Guns, Germs, and Steel", author: "Jared Diamond", category: "History", price: 20, in_stock: false, published_year: 1997, rating: 4.4 },
  { title: "The Silk Roads", author: "Peter Frankopan", category: "History", price: 28, in_stock: true, published_year: 2015, rating: 4.3 },
  { title: "A People's History of the US", author: "Howard Zinn", category: "History", price: 19, in_stock: true, published_year: 1980, rating: 4.2 },
  { title: "The Gulag Archipelago", author: "Aleksandr Solzhenitsyn", category: "History", price: 30, in_stock: true, published_year: 1973, rating: 4.8 },
  { title: "A Brief History of Time", author: "Stephen Hawking", category: "Science", price: 21, in_stock: true, published_year: 1988, rating: 4.6 },
  { title: "The Selfish Gene", author: "Richard Dawkins", category: "Science", price: 23, in_stock: true, published_year: 1976, rating: 4.5 },
  { title: "Cosmos", author: "Carl Sagan", category: "Science", price: 26, in_stock: false, published_year: 1980, rating: 4.8 },
  { title: "Astrophysics for People in a Hurry", author: "Neil deGrasse Tyson", category: "Science", price: 18, in_stock: true, published_year: 2017, rating: 4.4 },
  { title: "The Gene", author: "Siddhartha Mukherjee", category: "Science", price: 27, in_stock: true, published_year: 2016, rating: 4.6 },
  { title: "Silent Spring", author: "Rachel Carson", category: "Science", price: 20, in_stock: true, published_year: 1962, rating: 4.3 },
  { title: "Thinking, Fast and Slow", author: "Daniel Kahneman", category: "Business", price: 29, in_stock: true, published_year: 2011, rating: 4.6 },
  { title: "Zero to One", author: "Peter Thiel", category: "Business", price: 24, in_stock: true, published_year: 2014, rating: 4.4 },
  { title: "The Lean Startup", author: "Eric Ries", category: "Business", price: 26, in_stock: true, published_year: 2011, rating: 4.3 },
  { title: "Good to Great", author: "Jim Collins", category: "Business", price: 25, in_stock: false, published_year: 2001, rating: 4.2 },
  { title: "Atomic Habits", author: "James Clear", category: "Business", price: 22, in_stock: true, published_year: 2018, rating: 4.8 },
  { title: "Principles", author: "Ray Dalio", category: "Business", price: 65, in_stock: true, published_year: 2017, rating: 4.5 },
  { title: "The Hobbit", author: "J.R.R. Tolkien", category: "Fiction", price: 16, in_stock: true, published_year: 1937, rating: 4.9 },
  { title: "Educated", author: "Tara Westover", category: "History", price: 21, in_stock: true, published_year: 2018, rating: 4.7 },
  { title: "The Innovators", author: "Walter Isaacson", category: "Business", price: 30, in_stock: false, published_year: 2014, rating: 4.5 },
  { title: "Why We Sleep", author: "Matthew Walker", category: "Science", price: 24, in_stock: true, published_year: 2017, rating: 4.4 },
  { title: "Effective Java", author: "Joshua Bloch", category: "Programming", price: 47, in_stock: true, published_year: 2018, rating: 4.8 }
]);

// Перевірка Task 1:
db.books.countDocuments();
db.books.distinct("category");
db.books.distinct("author");


// TASK 2. CRUD Operations

// CREATE: 5 додаткових книг
db.books.insertMany([
  { title: "To Kill a Mockingbird", author: "Harper Lee", category: "Fiction", price: 14, in_stock: true, published_year: 1960, rating: 4.8 },
  { title: "The Wright Brothers", author: "David McCullough", category: "History", price: 22, in_stock: true, published_year: 2015, rating: 4.6 },
  { title: "Shoe Dog", author: "Phil Knight", category: "Business", price: 20, in_stock: true, published_year: 2016, rating: 4.7 },
  { title: "The Immortal Life of Henrietta Lacks", author: "Rebecca Skloot", category: "Science", price: 19, in_stock: false, published_year: 2010, rating: 4.5 },
  { title: "Head First Design Patterns", author: "Eric Freeman", category: "Programming", price: 43, in_stock: true, published_year: 2004, rating: 4.6 }
]);

db.books.countDocuments(); -

// READ

db.books.find({ category: "Programming" });
db.books.find({ published_year: { $gt: 2015 } });
db.books.find({ price: { $gt: 40 } });
db.books.find({ in_stock: true });
db.books.find({ author: "Peter Thiel" });
db.books.find({ rating: { $gt: 4.5 } });

// UPDATE

db.books.updateOne(
  { title: "Head First Design Patterns" },
  { $set: { price: 40 } }
);
db.books.updateMany(
  { category: "Programming" },
  { $set: { in_stock: false } }
);
db.books.updateOne(
  { title: "Silent Spring" },
  { $inc: { rating: 0.3 } }
);

// DELETE

db.books.deleteMany(
  { title: { $in: ["Astrophysics for People in a Hurry", "The Gene"] } }
);

db.books.countDocuments();


// TASK 4

// Query performance analysis
db.books.find({
    category: "Programming",
    published_year: { $gte: 2020 }
}).explain("executionStats")

// 34 docs scaned
// Yes, COLLSCAN
// 2 ms

//Indexing
db.books.createIndex({ category: 1, published_year: 1 })

//Re-run Performance Analysis
db.books.find({
    category: "Programming",
    published_year: { $gte: 2020 }
}).explain("executionStats")

// 1 doc scaned
// No, IXSCAN (+ FETCH)
// 15 ms
