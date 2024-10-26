import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.stream.*;


// Класс для хранения информации о каждом ученике, его оценок и среднего балла.
class StudentGrade {
    private final String fullName;
    private final Map<String, Integer> grades;

    public StudentGrade(String fullName) {
        this.fullName = fullName;
        this.grades = new HashMap<>();
    }

    public String getFullName() {
        return fullName;
    }

    public void addGrade(String subject, int grade) {
        grades.put(subject, grade);
    }

    public Map<String, Integer> getGrades() {
        return grades;
    }

    // Метод для расчета среднего балла ученика по всем предметам.
    public double getAverageGrade() {
        return grades.values().stream()
                .mapToInt(Integer::intValue)
                .average()
                .orElse(0.0);
    }
}

// Класс для обработки файлов оценок, вычисления статистики и создания отчета.
class GradeAggregator {
    private final List<StudentGrade> students = new ArrayList<>();

    // Конструктор, который инициализирует агрегатор и загружает данные из файлов.
    public GradeAggregator(String directoryPath) throws IOException {
        loadGrades(directoryPath);
    }

    // Метод, который загружает данные об оценках из файлов.
    private void loadGrades(String directoryPath) throws IOException {
        Files.list(Paths.get(directoryPath))
                .filter(Files::isRegularFile) // Отбираем только файлы, игнорируя папки.
                .forEach(path -> {
                    if (isValidFileName(path.getFileName().toString())) { // Проверяем корректность имени файла.
                        try {
                            StudentGrade student = parseStudentFile(path);
                            if (student != null) {
                                students.add(student);
                            }
                        } catch (IOException e) {
                            System.err.println("Ошибка чтения файла: " + path.getFileName());
                        }
                    } else {
                        System.err.println("Некорректное название файла: " + path.getFileName());
                    }
                });
    }

    // Проверка корректности имени файла.
    private boolean isValidFileName(String fileName) {
//        return fileName.matches("^[А-Яа-я]+_[А-Яа-я]+_[А-Яа-я]+\\.txt$");
//        return fileName.matches("^[А-Яа-я]+[_\s]+[А-Яа-я]+[_\s]+[А-Яа-я]+\\.txt$");
        return fileName.matches("^[А-Яа-я]+[_ ]?[А-Яа-я]+[_ ]?[А-Яа-я]+\\.txt$");
    }

    // Метод для чтения и парсинга файла, проверка корректности его содержимого.
    private StudentGrade parseStudentFile(Path path) throws IOException {
        String fileName = path.getFileName().toString();
        String studentName = fileName.replace(".txt", "");
        StudentGrade student = new StudentGrade(studentName);

        List<String> lines = Files.readAllLines(path); // Чтение всех строк файла.
        for (String line : lines) {
            line = line.trim(); // Убираем лишние пробелы.
            if (line.isEmpty()) {
                continue; // Пропускаем пустые строки, в точ числе если они встречаются в конце файла.
            }

            String[] parts = line.split("-");
            if (parts.length == 2) {  // Проверка на наличие разделителя "–" .
                String subject = parts[0].trim();
                try {
                    int grade = Integer.parseInt(parts[1].trim());  // Парсим оценку.
                    if (grade >= 1 && grade <= 5) {  // Проверка оценки на диапазон.
                        student.addGrade(subject, grade);
                    } else {
                        throw new IllegalArgumentException("Оценка вне диапазона (1-5)");
                    }
                } catch (NumberFormatException e) {
                    System.err.println("Некорректная оценка в файле " + fileName + ": " + line);
                    return null;
                }
            } else {
                System.err.println("Некорректный формат строки в файле " + fileName + ": " + line);
                return null;
            }
        }
        // Проверяем, что у ученика есть хотя бы 5 оценок, иначе файл считается некорректным.
        return student.getGrades().size() >= 5 ? student : null;
    }


    // Метод для вывода отчета в консоль и записи его в файл.
    public void printReport(String reportFilePath) throws IOException {
        StringBuilder report = new StringBuilder();
        report.append("Количество учеников: ").append(students.size()).append("\n");

        report.append("\nСредний балл по каждому предмету:\n");
        Map<String, Double> subjectAverages = getSubjectAverageGrades();
        subjectAverages.forEach((subject, avg) ->
                report.append(subject).append(": ").append(String.format("%.2f", avg)).append("\n"));

        report.append("\nЛучшие ученики:\n");
        getTopStudents().forEach(student ->
                report.append(student.getFullName()).append(" - ").append(String.format("%.2f", student.getAverageGrade())).append("\n"));

        report.append("\nХудшие ученики:\n");
        getBottomStudents().forEach(student ->
                report.append(student.getFullName()).append(" - ").append(String.format("%.2f", student.getAverageGrade())).append("\n"));

        // Вывод содержимого файла в консоль.
        System.out.println("\n"+report.toString());
        // Сообщение о успешной записи нового файла.
        System.out.println("\nФайл успешно создан!");

        // Запись в файл отчета.
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(reportFilePath))) {
            writer.write(report.toString());
        }
    }

    // Метод для вычисления среднего балла по каждому предмету.
    public Map<String, Double> getSubjectAverageGrades() {
        Map<String, List<Integer>> subjectGrades = new HashMap<>();

        for (StudentGrade student : students) {
            for (Map.Entry<String, Integer> entry : student.getGrades().entrySet()) {
                String subject = entry.getKey();
                int grade = entry.getValue();
                subjectGrades
                        .computeIfAbsent(subject, k -> new ArrayList<>())
                        .add(grade);
            }
        }

        // Подсчитываем средний балл по каждому предмету.
        return subjectGrades.entrySet().stream()
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        entry -> entry.getValue().stream()
                                .mapToInt(Integer::intValue)
                                .average()
                                .orElse(0.0)
                ));
    }

    // Метод для определения худших учеников (минимальный средний балл).
    public List<StudentGrade> getTopStudents() {
        double maxAverage = students.stream()
                .mapToDouble(StudentGrade::getAverageGrade)
                .max()
                .orElse(0.0);
        return students.stream()
                .filter(s -> Double.compare(s.getAverageGrade(), maxAverage) == 0)
                .collect(Collectors.toList());
    }

    public List<StudentGrade> getBottomStudents() {
        double minAverage = students.stream()
                .mapToDouble(StudentGrade::getAverageGrade)
                .min()
                .orElse(0.0);
        return students.stream()
                .filter(s -> Double.compare(s.getAverageGrade(), minAverage) == 0)
                .collect(Collectors.toList());
    }
}

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);

        System.out.println("Введите путь к папке с файлами оценок:");
        String directoryPath = scanner.nextLine();

        try {
            String reportFilePath = directoryPath + "/отчет.txt";

            // Удаляем файл отчета, если он уже существует, чтобы создать новый отчет.
            Files.deleteIfExists(Paths.get(reportFilePath));

            // Инициализируем агрегатор и создаем отчет.
            GradeAggregator aggregator = new GradeAggregator(directoryPath);
            aggregator.printReport(reportFilePath);

        } catch (IOException e) {
            System.err.println("Ошибка при обработке файлов: " + e.getMessage());
        }
    }
}
