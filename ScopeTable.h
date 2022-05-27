#ifndef COMPILER_SCOPETABLE_H
#define COMPILER_SCOPETABLE_H

#include "SymbolInfo.h"
#include <iostream>
#include <sstream>

using namespace std;

namespace std
{
    template <typename T>
    std::string to_string(const T &value)
    {
        std::ostringstream ss;
        ss << value;
        return ss.str();
    }
}

class ScopeTable
{
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize, id, children;
    std::string tableID;

public:
    ScopeTable(int n, ScopeTable *parent = NULL)
    {
        bucketSize = n;
        children = 0;
        if (parent != NULL)
        {
            id = parent->getChildrenNum();
            tableID = parent->getTableID() + "." + std::to_string(id);
            this->parentScope = parent;
        }
        else
        {
            id = 1;
            tableID = std::to_string(id);
            parentScope = NULL;
        }

        table = new SymbolInfo *[n];
        for (int i = 0; i < n; i++)
        {
            table[i] = NULL;
        }
    }

    int hashFunc(std::string name) const
    {
        return sdbm(name.c_str()) % bucketSize;
    }

    static unsigned long sdbm(const char *str)
    {
        unsigned long hash = 0;
        int c;

        while (c = *str++)
            hash = c + (hash << 6) + (hash << 16) - hash;

        return hash;
    }

    int getChildrenNum() { return children; }

    int getID() { return id; }

    std::string getTableID() { return tableID; }

    void setChildrenNum(int n) { this->children = n; }

    void increaseChildrenNum(int n) { this->children += n; }

    void decreaseChildrenNum(int n) { this->children -= n; }

    void setID(int n)
    {
        this->id = n;
        std::string pTableID = this->parentScope->getTableID();
        this->tableID += pTableID + "." + std::to_string(id);
    }

    void setTableID(std::string s) { this->tableID = s; }

    ScopeTable *getParentScope() { return this->parentScope; }

    void setParentScope(ScopeTable *p)
    {
        this->parentScope = p;
        std::string pID = p->getTableID();
        this->id = p->getChildrenNum();
        this->tableID = pID + "." + std::to_string(id);
    }

    bool Insert(std::string name, std::string type)
    {
        int index = hashFunc(name);

        // if the bucket is blank
        if (table[index] == NULL)
        {
            table[index] = new SymbolInfo(name, type);
            std::string s = "Inserted in ScopeTable# " + this->getTableID() + " at position ";
            cout << s << index << ", 0" << endl;
            return true;
        }

        // collision occurred
        else
        {
            SymbolInfo *root = table[index];
            // if symbol is at level-0
            if (root->getNextSymbolInfo() == NULL && root->getName() == name)
            {
                // duplicate found at level 0
                if (root->getType() == type)
                {
                    std::string s = "< " + name + " , " + type + " >" + " already exists in current ScopeTable\n";
                    cout << s;
                    return false;
                }
            }
 
            while (root->getNextSymbolInfo() != NULL)
            {
                if (root->getName() == name)
                {
                    if (root->getType() == type)
                    {
                        std::string s = "< " + name + " , " + type + " >" + " already exists in current ScopeTable\n";
                        cout << s;
                        return false;
                    }
                }
                root = root->getNextSymbolInfo();
            }

            root = table[index];
            SymbolInfo *newSymbolInfo = new SymbolInfo(name, type);
            int i = 0;

            while (root->getNextSymbolInfo() != NULL)
            {
                root = root->getNextSymbolInfo();
                i++;
            }
            root->setNextSymbolInfo(newSymbolInfo);
            std::string s = "Inserted in ScopeTable# " + this->getTableID() + " at position ";
            cout << s << index << ", " << i + 1 << endl;

            return true;
        }
    }

    SymbolInfo *LookUp(std::string symbol)
    {
        int index = hashFunc(symbol);
        SymbolInfo *head = table[index];

        if (head == NULL)
        {
            return NULL;
        }
        else
        {
            int i = 0;
            while (head != NULL)
            {
                if (head->getName() == symbol)
                {
                    cout << "Found in ScopeTable# " << this->getTableID() << " at position " << index << ", " << i;
                    cout << endl;
                    return head;
                }
                i++;
                head = head->getNextSymbolInfo();
            }
        }
        return NULL;
    }

    bool Delete(std::string name)
    {
        int index = hashFunc(name);

        SymbolInfo *head = table[index];
        SymbolInfo *temp, *p, *q;

        if (head == NULL)
        {
            return false;
        }
        else if (head->getNextSymbolInfo() == NULL)
        {
            if (head->getName() == name)
            {
                delete head->getNextSymbolInfo();
                delete head;
                table[index] = NULL;
                cout << "Found in ScopeTable# " << this->getTableID() << " at position " << index << ", 0";
                cout << endl;
                cout << "Deleted Entry " << index << ", 0 from current ScopeTable";
                cout << endl;
                return true;
            }
            else
            {
                return false;
            }
        }
        else if (head->getNextSymbolInfo() != NULL)
        {
            if (head->getName() == name)
            {
                temp = table[index];
                table[index] = table[index]->getNextSymbolInfo();
                temp->setNextSymbolInfo(NULL);
                delete temp->getNextSymbolInfo();
                delete temp;

                cout << "Found in ScopeTable# " << this->getTableID() << " at position " << index << ", 0";
                cout << endl;
                cout << "Deleted Entry " << index << ", 0 from current ScopeTable";
                cout << endl;
                return true;
            }
            else
            {
                p = head;
                q = head->getNextSymbolInfo();
                int i = 1;

                while (q != NULL)
                {
                    if (q->getName() == name)
                    {
                        p->setNextSymbolInfo(q->getNextSymbolInfo());
                        q->setNextSymbolInfo(NULL);

                        delete q->getNextSymbolInfo();
                        delete q;

                        cout << "Found in ScopeTable# " << this->getTableID() << " at position " << index << ", " << i;
                        cout << endl;
                        cout << "Deleted Entry " << index << ", " << i << " from current ScopeTable";
                        cout << endl;
                        return true;
                    }
                    else
                    {
                        p = q;
                        q = q->getNextSymbolInfo();
                        i++;
                    }
                }
                return false;
            }
        }
    }

    void Print()
    {
        cout << endl
             << "ScopeTable # " << this->getTableID() << endl;
        for (int i = 0; i < bucketSize; i++)
        {
            cout << i << " --> ";
            if (table[i] == NULL)
            {
                cout << endl;
                continue;
            }
            else
            {
                SymbolInfo *temp = table[i];
                while (temp != NULL)
                {
                    cout << " < " << temp->getName() << " : " << temp->getType() << " > ";
                    temp = temp->getNextSymbolInfo();
                }
            }
            cout << " " << endl;
        }
        cout << endl;
    }

    ~ScopeTable()
    {
        for (int i = 0; i < bucketSize; i++)
        {
            if (table[i] != NULL)
            {
                delete table[i]->getNextSymbolInfo();
                delete table[i];
            }
        }
        delete[] table;
    }
};

#endif
