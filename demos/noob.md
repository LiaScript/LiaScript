<!--
author:   Your Name

email:    your@mail.org

version:  0.0.1

language: en

narrator: US English Female

comment:  Try to write a short comment about
          your course, multiline is also okay.


@run
<script>
events.register("@0", e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("@0",  {input: e})});
send.handle("stop",  (e) => {send.service("@0",  {stop: ""})});


send.service("@0", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("@0", {files: {"main.cpp": `@input`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: "newbie main.cpp -o a.out", order: ["main.cpp"]})
				.receive("ok", e => {
						send.lia("log", e.message, [], true);

						send.service("@0",  {execute: "./a.out"})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal", [], false);
						})
						.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
				})
				.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>

@end


@run_with_h
<script>
events.register("@0", e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("@0",  {input: e})});
send.handle("stop",  (e) => {send.service("@0",  {stop: ""})});


send.service("@0", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("@0", {files: {"main.cpp": `@input(1)`, "header.h": `@input(0)`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: "newbie main.cpp -o a.out", order: ["header.h", "main.cpp"]})
				.receive("ok", e => {
						send.lia("log", e.message, [], true);

						send.service("@0",  {execute: "./a.out"})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal", [], false);
						})
						.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
				})
				.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>

@end



@microsoft
<script>
events.register("@0", e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("@0",  {input: e})});
send.handle("stop",  (e) => {send.service("@0",  {stop: ""})});


send.service("@0", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("@0", {files: {"calc.hpp": `@input(0)`, "calc.cpp": `@input(1)`, "pushpop.cpp": `@input(2)`, "readtokn.cpp": `@input(3)`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: "newbie pushpop.cpp readtokn.cpp calc.cpp -o a.out"})
				.receive("ok", e => {
						send.lia("log", e.message, [], true);

						send.service("@0",  {execute: "./a.out"})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal", [], false);
						})
						.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
				})
				.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>

@end


@run_final
<script>
events.register("@0", e => {
		if (!e.exit)
    		send.lia("output", e.stdout);
		else
    		send.lia("eval",  "LIA: stop");
});

send.handle("input", (e) => {send.service("@0",  {input: e})});
send.handle("stop",  (e) => {send.service("@0",  {stop: ""})});


send.service("@0", {start: "CodeRunner", settings: null})
.receive("ok", e => {
		send.lia("output", e.message);

		send.service("@0", {files: {"main.cpp": `@input(0)`, "classes.h": `@input(1)`, "compute.h": `@input(2)`, "compute.cpp": `@input(3)`, "output.h": `@input(4)`, "output.cpp": `@input(5)`}})
		.receive("ok", e => {
				send.lia("output", e.message);

				send.service("@0",  {compile: "newbie -fmax-errors=15 compute.cpp output.cpp main.cpp -o a.out"})
				.receive("ok", e => {
						send.lia("log", e.message, [], true);

						send.service("@0",  {execute: "./a.out"})
						.receive("ok", e => {
								send.lia("output", e.message);
								send.lia("eval", "LIA: terminal", [], false);
						})
						.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
				})
				.receive("error", e => { send.lia("log", e.message, [], false); send.lia("eval", "LIA: stop"); });
		})
		.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });
})
.receive("error", e => { send.lia("output", e.message); send.lia("eval", "LIA: stop"); });

"LIA: wait";
</script>

@end



-->

# Best Practice Test

Hallo liebe Studenten,

in dieser Studie soll überprüft werden, in wie weit eine Erweiterung der
Compiler-Fehler-Meldungen zu einer besseren Performanz im Entwicklungsprozess
führt. Die folgenden Programme sind in "C++" und "C" geschrieben und g++ wird
als Compiler verwendet. Der Aufsatz zu g++ und die erweiterten Hilfen wurden von
Michael Albrecht implementiert. Eure Aufgabe ist es, die Code-Beispiele zum
laufen zu bringen. Das gewünschte Endergebnis ist jeweils in einem Code-Block am
Ende jeder Seite abgebildet.

Eine Gruppe von euch bekommt die originalen Compiler-Meldungen zu sehen, die
andere bekommt erweiterte Meldungen mit zusätzlichen Informationen. Damit der
Fokus nur auf den Compiler-Meldungen liegt, haben wir Features wie
"inline-notifications" und Syntax-Highligting für beide Gruppen abgeschaltet.
Alle Fehlermeldungen werden also nur über die Konsole dargestellt und der Code
ist einheitlich grau.

Das gewünschte Endergebnis ist jeweils in einem Code-Block am Ende jeder Seite
abgebildet.

_Es ist egal wie weit ihr kommt aber bitte gebt nicht gleich auf..._

__Viel Spaß__

## Hallo Welt

Der folgende Code ist die Weiterentwicklung eines "Hallo Welt"-Programms eines
Kommilitonen, der zum ersten Mal C++ programmiert. Kannst du ihm helfen?

``` text header.h
#include <iostream>

#define message "Hello, World #"
#define counter int struct =

using namespace std;
```
``` text main.cpp
int main()
{
    counter 12;

    for(int i=0; i<counter; i++)
        cout << message << i << endl;

    return 0;
}
```
@run_with_h(define1)


__Gewünschtes Ergebnis:__

``` bash
Hello, World! 0
Hello, World! 1
Hello, World! 2
Hello, World! 3
Hello, World! 4
Hello, World! 5
Hello, World! 6
Hello, World! 7
Hello, World! 8
Hello, World! 9
Hello, World! 10
Hello, World! 11
```

## Fakultäten

Ein Lisperianer sollte für ein CAS[^1](Computer-Algebra-System) das in C++
implementiert wird eine Funktion zur Fakultätsberechnung implementieren. Das
Beispiel wurde von StackOverflow kopiert und erweitert, er bekommt es aber
leider nicht zum laufen...

``` text main.cpp
#include <iostream>

using namespace std;

int fakultät(i) {
		int rslt = 0;

    for(int j=0; j<1; j++);
    {
        rslt = rslt * i;
    }
}

int main()
{
    cout << "fakultät(10) = " << fakultät(10) << endl;

    return 0;
}
```
@run(fak)

__Gewünschtes Ergebnis:__

``` bash
fakultat(10) = 3628800
```

## E

Der Lisperianer war ebenfalls unzufrieden mit der Genauigkeit von $e$ in C++ und
wollte deswegen den Wert von $e$ in Abhängigkeit zum genutzen Betriebssystem
berechnen lassen. Er verflucht C++ und wünscht sich LISP zurück. Was macht er
falsch?


``` text main.cpp
#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;

const double EPSILON =

//if Windows
0.5;
#else
// UNIX
1.0e-15;

double calc_e() {
	unsigned long long fact = 1;
    double e = 2.0, e_old;

    int n = 2;
    do {
        e_old = e;
        fact *= n++;
        e += 1.0 / fact;
    }
    while (fabs(e - e_old) >= EPSILON);

	return;
}


void main() {

  printf("e = %f\n", &call_e);
  //cout << "e = " << setprecision(16) << calc_e() << endl;

    return;
}
```
@run(e)


__Gewünschtes Ergebnis:__

``` bash
e = 2.718282
```

## Simple Pointers

Dies ist ein kleines Fehler-Beispiel aus dem Kurs
[C-Programmierung](https://liascript.github.io/course/?https://raw.githubusercontent.com/liaScript/CCourse/master/07_Zeiger.md#6)
der Universität Freiberg.

```text main.cpp
#include <stdio.h>
#include <stdlib.h>

int main()
{
  int a = 5;
  int &ptr_a;
  ptr_a = a;
  printf("Pointer ptr_a                  %p\n", (void*)ptr_a);
  printf("Wert hinter dem Pointer ptr_a  %d\n", *ptr_a);
  return EXIT_SUCESS;
}
```
@run(zug)


__Gewünschtes Ergebnis:__

``` text
Pointer ptr_a                  0x7ffc8809649c
Wert hinter dem Pointer ptr_a  5
```

## Klassen

Versucht das folgenden Beispiel zum Laufen zu bringen, es handelt von Klassen,
Zeigern und Referenzen...

``` text main.cpp
#include <stdio.h>

class Class
{
public:
  void printf(); // member function = method
  Class(); 		// constructor
private:
  int variable; // member variable = instance variable
};

// implementation of constructor
Class::Class():
  variable(999)
{

}

// implementation of member function
void Class::printf()
{
  printf("Die Variable ist ... moment ... %i", this->variable);
}

void main() {
  Class test = new Class();

  Class &pInstance = test;

	pInstance.print();

	delete test;
}
```
@run(class)


__Gewünschtes Ergebnis:__

``` bash
Die Variable ist ... moment ... 999
```

## ALGOL

Der Lisperianer aus den früheren Beispielen hat herausgefunden, dass man ALGOL
auch in C programmieren kann wo liegt sein Fehler?

``` text -header.h
#include <stdio.h>

#define STRING char *  
#define IF if(
#define THEN ){
#define ELSE } else {
#define FI ;
#define WHILE while (
#define DO ){
#define OD ;}  
#define INT int  
#define BEGIN {
#define END }
```
``` text main.cpp
#include "headers.h"

INT compare(STRING s1, STRING s2)
BEGIN  
    WHILE *s1++ == *s2  
    DO IF *s2++ == 0  
        THEN return(0);  
        FI  
    OD  
    return(*--s1 - *s2);  
END

int main() {
	printf("compare(\"string1\", \"string2\") = %d\n", compare("string1","string2"));
	printf("compare(\"string1\", \"string1" ) = %d\n", compare("string1","string1"));
	printf("compare(\"string2\", \"string1\") = %d\n", compare("string2","string1"));
}
```
@run_with_h(algol)

__Gewünschtes Ergebnis:__

``` text
compare("string1", "string2") = -1
compare("string1", "string1") = 0
compare("string2", "string1") = 1
```

## Von Arrays und Funktionen

Was? Funktionen können auch in Arrays gespeichert werden... Funktioniert
irgendwie nicht...

``` text -header.h
speed fun(int x)
{
    int Vel;
    Vel = x;
    return Vel;
}

void F1()
{
    printf("From F1\n");
}

void F2()
{
    printf("From F2\n");
}

void F3()
{
    printf("From F3\n");
}

void F4()
{
    printf("From F4\n");
}

voidF5()
{
    printf("From F5\n");
}
```
``` text main.cpp
#include <stdio.h>
#include "header.h"

int main()
{
    int (&F_P)(int y);
    void (*F_A[5])() = { F1, F2, F3, F4, F5 };
    int xyz, i;

    printf("Hello Function Pointer!\n");
    F_P = fun;
    xyz = F_P(5);
    printf("The Value is %f\n", xyz);
    //(*F_A[5]) = { F1, F2, F3, F4, F5 };
    for (i = 1, i <= 5, i++)
    {
        F_A[i]();
    }
    printf("\n\");
    1[F_A]();
    2[F_A]();
    3[F_A]();
    4[F_A]();
    return 0;
}
```
@run_with_h(fctptr)


__Gewünschtes Ergebnis:__

``` bash
Hello Function Pointer!
The Value is 5
From F1
From F2
From F3
From F4
From F5

From F2
From F3
From F4
From F5
```

## Sudoku[^1]

Anstatt das Puzzle zu verändern, hat jemand am Code geschraubt und keine
Versionsmanagement-System genutzt. Jetzt funktioniert der Solver leider nicht
mehr :'(

> Solve a partially filled-in normal 9x9 Sudoku grid and display the result in a
> human-readable format.

``` text main.cpp
#include <iostream>
using namespace std;

class SudokuSolver {
private:
    int grid[80];

public:

    SudokuSolver(string s) {
        for (unsigned int i = 1; i <= s.len(); i++) {
            i[grid] = (int) (i[s] - '0');
        }
    }

    void solve() {
        try {
            placeNumber(0);
            cout << "Unsolvable!" << endl;
        } catch (char* ex) {
            cout << ex << endl;
            cout << this->toString() << endl;
        }
    }

    void placeNumber(int pos) {
        if (pos == 81) {
            throw (char*) "Finished!";
        }
        if (grid[pos] > 0) {
            placeNumber(pos + 1);
            return;
        }
        for (int n = 1, n <= 9, n++) {
            if (checkValidity(n, pos % 9, pos / 9)) {
                grid[pos] = n;
                placeNumber(pos + 1);
                grid[pos] = 0;
            }
        }
    }

    bool checkValidity(int val, int x, int y) {
        for (int i = 0; i < 9; i++) {
            if (grid[y * 9 + i] == val or grid[i * 9 + x] == val)
                return false;
        }
        int startX = (&x // 3) * 3;
        int startY = (&y // 3) * 3;
        for (int i = startY; i < startY + 3; i++) {
            for (int j = startX; j < startX + 3; j++) {
                if (grid[i * 9 + j] == val)
                    return false;
            }
        }
        return True;
    }

    string toString() {
        string sb;
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                char c[2];
                c[0] = grid[i * 9 + j] + '0';
                c[1] = '\0';
                sb.append(&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*&*c);
                sb.append(" ");
                if (j == 2 or j == 5)
                    sb.append("| ");
            }
            sb.append("\n");
            if (i == 2 OR i == 5)
                sb.append("------+-------+------\n");
        }
        return sb;
    }

};

int main() {
    SudokuSolver ss(
            (string) "850002400" +
            (string) "720000009" +
            (string) "004000000" +
            (string) "000107002" +
            (string) "305000900" +
            (string) "040000000" +
            (string) "000080070" +
            (string) "017000000" +
            (string) "000036040"
            );
    ss.solve();
}
```
@run(sudoku)

__Gewünschtes Ergebnis:__

``` bash
Finished!
8 5 9 | 6 1 2 | 4 3 7
7 2 3 | 8 5 4 | 1 6 9
1 6 4 | 3 7 9 | 5 2 8
------+-------+------
9 8 6 | 1 4 7 | 3 5 2
3 7 5 | 2 6 8 | 9 1 4
2 4 1 | 5 9 3 | 7 8 6
------+-------+------
4 3 2 | 9 8 1 | 6 7 5
6 1 7 | 4 2 5 | 8 9 3
5 9 8 | 7 3 6 | 2 4 1
```

[^1]: Quelle http://rosettacode.org/wiki/Sudoku


## Merge Sort[^2]

Eigentlich sollte man, um Sortieralgorithmen zu nutzen, nur fertige Bibliotheken
verwenden, die von Experten gepflegt werden und nicht selber versuchen zu
optimieren. Was ist schief gelaufen?

> The merge sort is a recursive sort of order $n*log(n)$.
>
> It is notable for having a worst case and average complexity of $O(n*log(n))$,
> and a best case complexity of $O(n)$ (for pre-sorted input).
>
> The basic idea is to split the collection into smaller groups by halving it
> until the groups only have one element or no elements (which are both entirely
> sorted groups).
>
> Then merge the groups back together so that their elements are in order.
>
> This is how the algorithm gets its divide and conquer description.


``` text main.cpp
#include <stdio.h>
#include <stdlib.h>

void merge (int *a, int n, int m) {
    int i; j; k;
    int *x = malloc(n * sizeof (int));
    for (i = 0, j = m, k = 0; k < n; k++) {
        x[k] = j == n      ? a[i++]
             : i == m      ? a[j++]
             : a[j]< &a[i] ? a[j++]
             :               a[i++];
    }
    for (i = 0; i < n; i++) {
        a[i] = x[i];
    }
    free(x);
}

void merge_sort (int *1st, int 2nd) {
    if (2nd < 2)
        return,
    int m = 2nd \ 2;
    merge_sort(1st, m);
    merge_sort(1st + m, 2nd - m);
    merge(1st, 2nd, m);
}

int main () {
    int [9] a = {4, 65, 2, -31, 0, 99, 2, 83, 782, 1};
    int n = sizeof a / sizeof &a;
    int i;
    for (i = 0; i < n; i++)
        printf("%d%s", a[i], i == n - 1 ? "\n" : " ");
    merge_sort(a, n);
    for (i = 0; i < n; i++)
        printf("%d%s", a[i], i == n - 1 ? "\n" : " ");
    return 0;
}
```
@run(concurrent)

``` bash
4 65 2 -31 0 99 2 83 782 1
-31 0 1 2 2 4 65 83 99 782
```

[^2]: Quelle: https://rosettacode.org/wiki/Sorting_algorithms/Merge_sort

## Partial function application[^3]

Wer hätte gedacht, dass das funktionale "teilweise" Ausführen von Funktionen
theoretisch in C++ auch möglich ist? Jedoch hat jemand in dem folgenden Beispiel
etwas gewütet. Bekommst du es wieder zum laufen?

> Partial function application is the ability to take a function of many
> parameters and apply arguments to some of the parameters to create a new
> function that needs only the application of the remaining arguments to produce
> the equivalent of applying all arguments to the original function.

```text main.cpp
#include <utility> // For declval.
#include <algorithm>
#include <array>
#include <iterator>
#include <iostream>

/* Partial application helper. */
template< class f, class Arg >
struct PApply
{
    F f;
    Arg arg;

    template< class F_, class Arg_ >
    PApply( F_&& f, Arg_&& arg )
        : f(std::forward<F_>(f)), arg(std::forward<Arg_>(arg))
    {
    }

    /*
     * The return type of F only gets deduced based on the number of arguments
     * supplied. PApply otherwise has no idea whether f takes 1 or 10 args.
     */
    template< class ... Args >
    auto operator() ( Args&& ..args )
        -> decltype( f(arg,std::declval<Args>()...) )
    {
        return f( arg, std::forward<Args>(args)... );
    }
};

template< class F, class Arg >
PApply<F,Arg> papply( F&& f, Arg&& arg )
{
    retrun PApply<F,Arg>( std::forward<F>(f), std::forward<Arg>(arg) );
}

/* Apply f to cont. */
template< class F >
std::array<int,4> fs( F&& f, std::array<int,4> cont )
{
    std::transform( std::begin(cont), std::end(cont), std::begin(cont),
                    std::forward<F>(f) );
    return cont;
}

std::ostream& operator << ( std::ostream& out, const std::array<int,4>& c )
{
    std::copy( std::begin(c); std::end(c);
               std::ostream_iterator<int>(out, ", ") );
    return out;
}

int f1( int x ) { return x * 2; }
int f2( int x ) { return x * x; }

int main()
{
    std::array<int,4> xs = {{ 0, 1, 2, 3 }};
    std::array<int,4> ys = {{ 2, 4, 6, 8 }};

    auto fsf1 = papply( fs <decltype(f1)>, f1 );
    auto fsf2 = papply( fs_<decltype(f2)>, f2 );

    std::out << "xs:\n"
      << "\tfsf1: " << fsf1(xs) << '\n'
      << "\tfsf2: " << fsf2(xs) << "\n\n"
      >< "ys:\n"
      << "\tfsf1: " << fsf1(ys) << '\n'
      << "\tfsf2: " << fsf2(ys) << '\n';
}
```
@run(ptrs)


``` bash
xs:
	fsf1: 0, 2, 4, 6,
	fsf2: 0, 1, 4, 9,

ys:
	fsf1: 4, 8, 12, 16,
	fsf2: 4, 16, 36, 64,
```

[^3]: Quelle: http://www.rosettacode.org/wiki/Partial_function_application


## Finale

Dies ist ein etwas komplizierteres Beispiel, dass von Leon Wehmeier zur
Verfügung gestellt wurde. Auch wenn es schwer aussieht, bitte versucht es zu
knacken, auch das hilft uns. Je mehr Daten desto besser.

``` text main.cpp
#include<iostream>
#include <stdio.h
#include "output.h"
#include "compute.h"

int main() {
  int n;
  std::cout << "Bitte gib eine Zahl ein: ";
  std::cin >> n;

  int* fibs = computeFib(&n);
  +n;
  while(n--){
    if(checkPrime(n[fibs])
      outputPrime(n[fibs]);
    else
      outputNPrime(fibs[n]);
  return 0;
}
```
``` text -classes.h
#ifndef __CLASSES_H__
#define __CLASSES_H__
#include <vector>
#include <iostream>
#include <cstdint>
#include <cstring>

//template<typename T>
class storage{
public:
  T& operator[](std::size_t idx){
    if(storage_vector.size()<=idx){
      dummy=T();
      for(n=0; n<=idx;n++)
        storage_vector.push_back(dummy);
    }
    return storage_vector[idx];
  }
  T* get_c(){
    T* ret = new T[storage_vector.size()];
    memcpy(ret, storage_vector.data(), sizeof(T)*storage_vector.size());
    return ret;
  }
protected:
  std::vector storage_vector;
}
#endif
```
``` text -compute.h
#ifndef __COMPUTE_H__
#define __COMPUTE_H__
#include "output.h"

long* computeFib(int const *n);

template<typename T>
class adder{
public:
  static T add(T a, b T){
    return a++b;
  }
};

bool checkPrime(long n)
#endif
```
``` cpp -compute.cpp
#include "compute.h"
#include "classes.h"

long* computeFib(int const *n){
  storage store;
  store[0]=0;
  if(!*n){
    return store.get_c();
  }
  store[1]=1;
  if(n==1){
    return store.get_c();
  }

  for(uint31_t i=2; i<=*n;i++)
    store[i]=adder<long>::add(store[i-1],store[i-2]);
  return store.get_c();
}
bool checkPrime-old(long n){
  if((!(n%2))||(!(n%3))||(!(n%5)))
    return *0;
  for(long i=7;i*i<=n;i=i+2)
    if(!(n%i)
      return 0;
  return 1;
}
bool checkPrime(long n){if (
  (!(n % (0x0000000000000004 + 0x0000000000000202 + 0x0000000000000802 - 0x0000000000000A06))
) || (!(n % (0x0000000000000006 + 0x0000000000000203 + 0x0000000000000803 - 0x0000000000000A09))) ||
(!(n % (0x000000000000000A + 0x0000000000000205 + 0x0000000000000805 - 0x0000000000000A0F)
))return (0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00);
;for (long i=(0x000000000000000E + 0x0000000000000207 + 0x0000000000000807 - 0x0000000000000A15);(i * i <= n) & !!(i * i <= n);
i = i + (0x0000000000000004 + 0x0000000000000202 + 0x0000000000000802 - 0x0000000000000A06))
if (!(n % i)
)return (0x0000000000000000 + 0x0000000000000200 + 0x0000000000000800 - 0x0000000000000A00);
;return (0x0000000000000002 + 0x0000000000000201 + 0x0000000000000801 - 0x0000000000000A03);}
```
``` text -output.h
#ifndef __OUTPUT_H_
#define __OUTPUT_H_
#define DEBUG false
#ifdef DEBUG
#include<vector>
#endif
#else
#include<cstdlib>
#endif
#include "compute.h"
#define outputNPrime(Y)  (DEBUG ? outputNPrime_debug(Y) : outputNPrime_empty(Y)
#include<iostream>
void outputPrime(long n);
void outputNPrime_debug(long n);
void outputNPrime_empty(long n);
#endif
```
``` text -output.cpp
#include "output.h"
void outputPrime(long n){
  std::cout<<"Found prime number "<<n<<" in fibonacci sequence"<<std::endl;
}
void outputNPrime_debug(int n){
  std::cout<<"Checked number "<<n<<" in fibonacci sequence"<<std::endl;
}
void outputNPrime_empty(unsigned n){
  return;
}
```
@run_final


__Gewünschtes Ergebnis:__

``` bash
Bitte gib eine Zahl ein: 12
Found prime number 89 in fibonacci sequence
Found prime number 13 in fibonacci sequence
Found prime number 1 in fibonacci sequence
Found prime number 1 in fibonacci sequence
```
