use std:: fs::File;
use std::io:: {BufRead, BufReader, Write};
use std::path::Path;
use std::thread;
use std::time::Instant;


const INPUT_FILES: &[&str] = &["Table_1.csv","Table_2.csv","Table_3.csv",];

type BoxedError = Box<dyn std::error::Error + Send + Sync>;

fn main (){
    println!("Lets Begin");
    let start = Instant::now();
    for file in INPUT_FILES {
        if let Err(e) = process_file(file) {
            eprintln!("Error processing{}:{}", file,e);

        }
    }
    let duration = start.elapsed();
    println!("Sequential Execution Time: {:.2}", duration.as_secs_f64());

    println!("\nStarting multithreaded execution...");
    let start = Instant::now();
    let handles: Vec<_> = INPUT_FILES
        .iter()
        .map(|&file|{
            let file = file.to_string();
            thread::spawn(move|| process_file(&file).map_err(|e| e.to_string()))
        })
        .collect();

    for handle in handles {
        if let Err(e) = handle.join().unwrap_or_else(|_| Err("Thread panicked".to_string())){
            eprintln!("Error in thread: {}", e);
        }
    }
    let duration= start.elapsed();
    println!("Multithreaded Execution TIme: {:.2} seconds", duration.as_secs_f64());
}

fn process_file(file_path:&str) -> Result<(), BoxedError>{
    let file =File::open(file_path)?;
    let reader = BufReader ::new(file);
    let output_filename = format!("processed_{}", Path::new(file_path).file_name().unwrap().to_str().unwrap());
    let mut output_file = File::create(&output_filename)?;

    for line in reader.lines() {
        let line = line?;
        output_file.write_all(line.as_bytes())?;
        output_file.write_all(b"\n")?;
    }
    println!("Very Good")
    println!("Processed and saved: {}", output_filename);
    Ok(())

}


