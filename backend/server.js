const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const multer = require("multer");
const path = require("path");


const app = express();
app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));

// PostgreSQL connection
const pool = new Pool({
  user: "postgres",
  host: "localhost",
  database: "prolink",
  password: "7bsouna1",
  port: 5432,
});

//unified login
app.post("/login", async (req, res) => {
  const { email, password, role } = req.body;

  let table = "";

  if (role === "admin") table = "admins";
  else if (role === "mentor") table = "mentors";
  else if (role === "intern") table = "interns";
  else return res.status(400).json({ error: "Invalid role" });

  try {
    const result = await pool.query(
      `SELECT * FROM ${table} WHERE email=$1 AND password=$2`,
      [email, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: "Invalid credentials" });
    }

    res.json({
      role: role,
      user: result.rows[0]
    });

  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

//intern register
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/cv/");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const profileStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/profile/");
  },
  filename: (req, file, cb) => {
    cb(null, "profile_" + Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({
  storage,
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const mime = file.mimetype;

    if (ext === ".pdf" || mime === "application/pdf") {
      cb(null, true);
    } else {
      cb(new Error("Only PDF files are allowed"), false);
    }
  }
});
const uploadProfile = multer({ storage: profileStorage });

app.post("/register/intern", upload.single("cv"), async (req, res) => {
  const { email, password, fname, lname, age } = req.body;

  const cvPath = req.file ? req.file.path : null;

  try {
    const result = await pool.query(
      `INSERT INTO interns (email, password, fname, lname, age, cv)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING *`,
      [email, password, fname, lname, age, cvPath]
    );

    res.json(result.rows[0]);

  }catch (err) {
    console.error("REGISTER ERROR:", err);

    if (err.message === "Only PDF files are allowed") {
      return res.status(400).json({ error: err.message });
    }

    res.status(500).json({ error: err.message });
  }
});


//-------------------------------------Admin APIs-------------------------------------------------

//get waiting interns
app.get("/interns/pending", async (req, res) => {
  const result = await pool.query(
    "SELECT * FROM interns WHERE status='waiting'"
  );
  res.json(result.rows);
});

//get interns that are not assigned
app.get("/interns/waitingassignment", async (req, res) => {
  const result = await pool.query(
    "SELECT * FROM interns WHERE mentor_id is NULL AND status='accepted'"
  );
  res.json(result.rows);
});

//accept or reject intern
app.put("/interns/:id/status", async (req, res) => {
  const { id } = req.params;
  const { status } = req.body; // accepted or rejected

  await pool.query(
    "UPDATE interns SET status=$1 WHERE intern_id=$2",
    [status, id]
  );

//

  res.json({ message: "Updated" });
});

//assigning an intern to a mentor and a department
app.put("/interns/:id/assign", async (req, res) => {
  const { id } = req.params;
  const { mentor_id, department_id } = req.body;

  await pool.query(
    "UPDATE interns SET mentor_id=$1, department_id=$2, status='accepted' WHERE intern_id=$3",
    [mentor_id, department_id, id]
  );

  res.json({ message: "Intern assigned" });
});

//get departments
app.get("/departments", async (req, res) => {
  const result = await pool.query("SELECT * FROM departments");
  res.json(result.rows);
});

//get Mentors
app.get("/mentors", async (req, res) => {
  const result = await pool.query("SELECT * FROM mentors");
  res.json(result.rows);
});

//get mentors from a specific department
app.get("/departments/:id/mentors", async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      "SELECT * FROM mentors WHERE department_id = $1",
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch mentors" });
  }
});

//create schedule
app.post("/schedules/batch", async (req, res) => {
  const { mentor_id, days, start_time, end_time } = req.body;
  try {
    for (const day of days) {
      await pool.query(
        `INSERT INTO schedules (mentor_id, day_of_week, start_time, end_time)
         VALUES ($1, $2, $3, $4)`,
        [mentor_id, day, start_time, end_time]
      );
    }
    res.status(201).json({ message: "Schedules created" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
//-----------------------------------------Mentor APIs-------------------------------------
//get interns assigned to mentor
app.get("/mentor/:id/interns", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
        intern_id,
        fname,
        lname,
        email,
        picture_url
       FROM interns
       WHERE mentor_id = $1`,
      [id]
    );

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

//get skills
app.get("/intern/:id/skills", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT s.skill_id, s.skill
       FROM interns i
       JOIN skills s ON i.department_id = s.department_id
       WHERE i.intern_id = $1`,
      [id]
    );

    res.json(result.rows);

  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

//upload training models
const trainingStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/training/");
  },
  filename: (req, file, cb) => {
    cb(null, "module_" + Date.now() + path.extname(file.originalname));
  }
});
const uploadTraining = multer({
  storage: trainingStorage,
  fileFilter: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    if (ext === ".pdf") cb(null, true);
    else cb(new Error("Only PDF files allowed"), false);
  }
});
app.post("/training", uploadTraining.single("file"), async (req, res) => {
  const { mentor_id, name } = req.body;

  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = req.file.path;

    const result = await pool.query(
      `INSERT INTO training_modules (mentor_id, name, file_url)
       VALUES ($1,$2,$3) RETURNING *`,
      [mentor_id, name, filePath]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error("TRAINING ERROR:", err);
    res.status(500).json({ error: err.message });
  }
});

//add marks
app.post("/marks", async (req, res) => {
  const { intern_id, skill_id, mark } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO marks (intern_id, skill_id, mark)
       VALUES ($1,$2,$3)
       ON CONFLICT (intern_id, skill_id)
       DO UPDATE SET mark = EXCLUDED.mark
       RETURNING *`,
      [intern_id, skill_id, mark]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//attendance
app.post("/attendance", async (req, res) => {
  const { intern_id, date, status } = req.body;

  const result = await pool.query(
    `INSERT INTO attendance (intern_id, date, status)
     VALUES ($1,$2,$3) RETURNING *`,
    [intern_id, date, status]
  );

  res.json(result.rows[0]);
});


//-------------------------Intern API Calls -----------------------------
//fetch intern
app.get("/intern/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
        i.intern_id,
        i.fname,
        i.lname,
        i.email,
        i.picture_url,
        d.name AS department_name,
        m.fname AS mentor_fname
      FROM interns i
      LEFT JOIN departments d ON i.department_id = d.department_id
      LEFT JOIN mentors m ON i.mentor_id = m.mentor_id
      WHERE i.intern_id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Intern not found" });
    }

    res.json(result.rows[0]);

  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

//upload intern profile image
app.put("/intern/:id/picture", uploadProfile.single("picture"), async (req, res) => {
  const { id } = req.params;
    console.log("Request received");
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    const filePath = req.file.path;
    console.log(req.file);
    await pool.query(
      "UPDATE interns SET picture_url=$1 WHERE intern_id=$2",
      [filePath, id]
    );

    res.json({ message: "Picture updated", picture_url: filePath });

  } catch (err) {
    console.error("UPLOAD ERROR:", err); // 👈 ADD THIS
    res.status(500).json({ error: "Server error" });
  }
});

//get training modules
app.get("/intern/:id/training", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT t.*
       FROM interns i
       JOIN training_modules t
         ON t.mentor_id = i.mentor_id
       WHERE i.intern_id = $1`,
      [id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//get marks
app.get("/intern/:id/skills-with-marks", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT
        s.skill_id,
        s.skill,
        COALESCE(m.mark, 0) AS mark
       FROM interns i
       JOIN skills s
         ON (s.department_id = i.department_id OR s.department_id IS NULL)
       LEFT JOIN marks m
         ON m.skill_id = s.skill_id
         AND m.intern_id = i.intern_id
       WHERE i.intern_id = $1`,

      [id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//get schedule
app.get("/intern/:id/schedule", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT s.day_of_week, s.start_time, s.end_time
       FROM interns i
       JOIN schedules s
         ON s.mentor_id = i.mentor_id
       WHERE i.intern_id = $1
       ORDER BY
         CASE s.day_of_week
           WHEN 'Sat' THEN 1
           WHEN 'Sun' THEN 2
           WHEN 'Mon' THEN 3
           WHEN 'Tue' THEN 4
           WHEN 'Wed' THEN 5
           WHEN 'Thu' THEN 6
         END`,
      [id]
    );

    res.json(result.rows);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

//get average mark
app.get("/intern/:id/average-mark", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT COALESCE(AVG(mark), 0) AS avg_mark
       FROM marks
       WHERE intern_id = $1`,
      [id]
    );

    res.json(result.rows[0]);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});

app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));
// test connection
pool.connect()
  .then(() => console.log("✅ PostgreSQL connected"))
  .catch(err => console.error("❌ Connection error", err));

app.listen(3000, () => console.log("Server running on port 3000"));