#include <iostream>
#include <fstream>

// Задание рандомной плотности от 0.1 до 10
inline double RandomDensity() {
    const double min = 0.1;
    const double max = 10;
    double f = (double)rand() / RAND_MAX;
    return min + f * (max - min);
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cout << "expected: command number_of_shapes_to_generate\n";
        return 1;
    }
    std::ofstream ofstream("out.txt");
    int length = std::stoi(argv[1]);
    std::cout << "Старт\n";
    int var;
    for (int i = 0; i < length; i++) {
        var = rand() % 3 + 1;
        ofstream << var << "\n";
        // Определение типа фигуры
        switch (var) {
            case 3:
            case 1:
                ofstream << rand() % 256 + 1 << " " << RandomDensity() << "\n";
                break;
            case 2:
                ofstream << rand() % 256 + 1 << " ";
                ofstream << rand() % 256 + 1 << " ";
                ofstream << rand() % 256 + 1 << " ";
                ofstream << RandomDensity() << "\n";
                break;
        }
    }
    ofstream.close();
    std::cout << "Фигуры сгенерированы!\n";
    return 0;
}
